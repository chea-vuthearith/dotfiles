#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p python3Packages.tldextract

"""
qute-bitwarden: Bitwarden integration for qutebrowser

Usage:
    The domain of the site must be in the Bitwarden entry name, e.g. "github.com/cryzed" or "websites/github.com".
    Login info is inserted by emulating key events using qutebrowser's fake-key command:
    [USERNAME]<Tab>[PASSWORD], compatible with most login forms.

    If enabled with the `--totp` flag, the TOTP code is copied to the clipboard.

    You must log into Bitwarden CLI using `bw login` before using this script.
    The session key is stored using keyctl for the number of seconds passed to --auto-lock.

    To use in qutebrowser: `spawn --userscript qute-bitwarden`

Dependencies:
    - tldextract (Python 3 module)
    - pyperclip (optional, for TOTP codes)
    - Bitwarden CLI (1.7.4+ known to work)

WARNING: Login details are visible as plaintext in qutebrowser's debug log (qute://log).
"""

import argparse
import enum
import functools
import os
import shlex
import subprocess
import sys
import json
import tldextract

def parse_args():
    parser = argparse.ArgumentParser(
        description="Bitwarden integration for qutebrowser",
        usage="spawn --userscript qute-bitwarden [options] [url]",
        epilog="See script header for details and warnings.",
    )
    parser.add_argument('url', nargs='?', default=os.getenv('QUTE_URL'))
    parser.add_argument('--dmenu-invocation', '-d', default='fuzzel --dmenu -i',
                        help='Command to invoke dmenu provider')
    parser.add_argument('--password-prompt-invocation', '-p', default='fuzzel -d --password=* --prompt-only="Password: "',
                        help='Command to prompt for Bitwarden password')
    parser.add_argument('--no-insert-mode', '-n', dest='insert_mode', action='store_false',
                        help="Don't automatically enter insert mode")
    parser.add_argument('--totp', '-t', action='store_true',
                        help="Copy TOTP key to clipboard")
    parser.add_argument('--io-encoding', '-i', default='UTF-8',
                        help='Encoding for subprocess communication')
    parser.add_argument('--merge-candidates', '-m', action='store_true',
                        help='Merge pass candidates for FQDN and registered domain')
    parser.add_argument('--auto-lock', type=int, default=900,
                        help='Auto-lock vault after N seconds')
    group = parser.add_mutually_exclusive_group()
    group.add_argument('--username-only', '-e',
                       action='store_true', help='Only insert username')
    group.add_argument('--password-only', '-w',
                       action='store_true', help='Only insert password')
    group.add_argument('--totp-only', '-T',
                       action='store_true', help='Only insert TOTP code')
    return parser.parse_args()

class ExitCodes(enum.IntEnum):
    SUCCESS = 0
    FAILURE = 1
    NO_PASS_CANDIDATES = 2
    COULD_NOT_MATCH_USERNAME = 3
    COULD_NOT_MATCH_PASSWORD = 4

stderr = functools.partial(print, file=sys.stderr)

def qute_command(command: str):
    fifo_path = os.environ.get('QUTE_FIFO')
    if not fifo_path:
        stderr("QUTE_FIFO environment variable not set.")
        sys.exit(ExitCodes.FAILURE)
    with open(fifo_path, 'w') as fifo:
        fifo.write(f"{command}\n")
        fifo.flush()

def ask_password(password_prompt_invocation: str) -> str:
    process = subprocess.run(
        shlex.split(password_prompt_invocation),
        text=True,
        stdout=subprocess.PIPE,
    )
    if process.returncode > 0:
        raise Exception('Could not unlock vault')
    master_pass = process.stdout.strip()
    return subprocess.check_output(
        ['bw', 'unlock', '--raw', '--passwordenv', 'BW_MASTERPASS'],
        env={**os.environ, 'BW_MASTERPASS': master_pass},
        text=True,
    ).strip()

def get_session_key(auto_lock: int, password_prompt_invocation: str) -> str:
    if auto_lock == 0:
        subprocess.call(['keyctl', 'purge', 'user', 'bw_session'])
        return ask_password(password_prompt_invocation)
    process = subprocess.run(
        ['keyctl', 'request', 'user', 'bw_session'],
        text=True,
        stdout=subprocess.PIPE,
    )
    key_id = process.stdout.strip()
    if process.returncode > 0 or not key_id:
        session = ask_password(password_prompt_invocation)
        if not session:
            raise Exception('Could not unlock vault')
        key_id = subprocess.check_output(
            ['keyctl', 'add', 'user', 'bw_session', session, '@u'],
            text=True,
        ).strip()
    if auto_lock > 0:
        subprocess.call(['keyctl', 'timeout', str(key_id), str(auto_lock)])
    return subprocess.check_output(
        ['keyctl', 'pipe', str(key_id)],
        text=True,
    ).strip()

def bitwarden_list_items(domain: str, encoding: str, auto_lock: int, password_prompt_invocation: str) -> str:
    session_key = get_session_key(auto_lock, password_prompt_invocation)
    process = subprocess.run(
        ['bw', 'list', 'items', '--nointeraction', '--session', session_key, '--url', domain],
        capture_output=True,
    )
    err = process.stderr.decode(encoding).strip()
    if err:
        stderr(f"Bitwarden CLI returned for {domain} - {err}")
        if "Vault is locked" in err:
            stderr("Bitwarden Vault got locked, trying again with clean session")
            return bitwarden_list_items(domain, encoding, 0, password_prompt_invocation)
    if process.returncode:
        return '[]'
    return process.stdout.decode(encoding).strip()

def get_totp_code(selection_id: str, domain_name: str, encoding: str, auto_lock: int, password_prompt_invocation: str) -> str:
    session_key = get_session_key(auto_lock, password_prompt_invocation)
    process = subprocess.run(
        ['bw', 'get', 'totp', '--nointeraction', '--session', session_key, selection_id],
        capture_output=True,
    )
    err = process.stderr.decode(encoding).strip()
    if err:
        stderr(f"Bitwarden CLI returned for {domain_name} - {err}")
        if "Vault is locked" in err:
            stderr("Bitwarden Vault got locked, trying again with clean session")
            return get_totp_code(selection_id, domain_name, encoding, 0, password_prompt_invocation)
    if process.returncode:
        return '[]'
    return process.stdout.decode(encoding).strip()

def dmenu(items: list[str], invocation: str, encoding: str) -> str:
    command = shlex.split(invocation)
    process = subprocess.run(command, input='\n'.join(items).encode(encoding), stdout=subprocess.PIPE)
    return process.stdout.decode(encoding).strip()

def fake_key_raw(text: str):
    for character in text:
        sequence = '" "' if character == ' ' else fr'\{character}'
        qute_command(f'fake-key {sequence}')

def fill_form(username: str, password: str):
    """
    Returns a minified JavaScript string that fills visible login forms with the given username and password.
    """
    # Escape username and password for JS string literals
    import json
    js_username = json.dumps(username)
    js_password = json.dumps(password)
    js = f"""
    (function() {{
        function isVisible(elem) {{
            var style = elem.ownerDocument.defaultView.getComputedStyle(elem, null);
            if (style.getPropertyValue("visibility") !== "visible" ||
                style.getPropertyValue("display") === "none" ||
                style.getPropertyValue("opacity") === "0") {{
                return false;
            }}
            return elem.offsetWidth > 0 && elem.offsetHeight > 0;
        }}
        function hasPasswordField(form) {{
            var inputs = form.getElementsByTagName("input");
            for (var j = 0; j < inputs.length; j++) {{
                var input = inputs[j];
                if (input.type === "password") {{
                    return true;
                }}
            }}
            return false;
        }}
        function loadData2Form(form) {{
            var inputs = form.getElementsByTagName("input");
            for (var j = 0; j < inputs.length; j++) {{
                var input = inputs[j];
                if (isVisible(input) && (input.type === "text" || input.type === "email")) {{
                    input.focus();
                    input.value = {js_username};
                    input.dispatchEvent(new Event('change'));
                    input.blur();
                }}
                if (input.type === "password") {{
                    input.focus();
                    input.value = {js_password};
                    input.dispatchEvent(new Event('change'));
                    input.blur();
                }}
            }}
        }}
        var forms = document.getElementsByTagName("form");
        for (var i = 0; i < forms.length; i++) {{
            if (hasPasswordField(forms[i])) {{
                loadData2Form(forms[i]);
            }}
        }}
    }})();
    """
    minified= ' '.join(line.strip() for line in js.splitlines())
    qute_command(f'jseval {minified}')

def main(args):
    if not args.url:
        stderr("No URL provided.")
        return ExitCodes.FAILURE

    extract_result = tldextract.extract(args.url)
    candidates = []
    targets = [
        extract_result.fqdn,
        getattr(extract_result, "top_domain_under_public_suffix", None) or extract_result.registered_domain,
        f"{extract_result.subdomain}.{extract_result.domain}" if extract_result.subdomain else None,
        extract_result.domain,
        getattr(extract_result, "ipv4", None),
    ]
    for target in filter(None, targets):
        target_candidates = json.loads(
            bitwarden_list_items(
                target,
                args.io_encoding,
                args.auto_lock,
                args.password_prompt_invocation,
            )
        )
        if not target_candidates:
            continue
        candidates += target_candidates
        if not args.merge_candidates:
            break
    else:
        if not candidates:
            stderr(f"No pass candidates for URL '{args.url}' found!")
            return ExitCodes.NO_PASS_CANDIDATES

    if len(candidates) == 1:
        selection = candidates.pop()
    else:
        choices = [f"{c['login']['username']} | {c['name']}" for c in candidates]
        choice = dmenu(choices, args.dmenu_invocation, args.io_encoding)
        if not choice or '|' not in choice:
            return ExitCodes.SUCCESS
        choice_username, choice_name = map(str.strip, choice.split('|', 1))
        selection = next(
            (c for c in candidates if c['name'] == choice_name and c['login']['username'] == choice_username),
            None
        )

    if not selection:
        return ExitCodes.SUCCESS

    username = selection['login']['username']
    password = selection['login']['password']
    totp = selection['login'].get('totp')

    if args.totp_only:
        fake_key_raw(
            get_totp_code(
                selection['id'],
                selection['name'],
                args.io_encoding,
                args.auto_lock,
                args.password_prompt_invocation,
            )
        )
    else:
        fill_form(username, password)

    if args.insert_mode:
        qute_command('mode-enter insert')

    if not args.totp_only and totp and args.totp:
        try:
            import pyperclip
            pyperclip.copy(
                get_totp_code(
                    selection['id'],
                    selection['name'],
                    args.io_encoding,
                    args.auto_lock,
                    args.password_prompt_invocation,
                )
            )
        except ImportError:
            stderr("pyperclip not installed, cannot copy TOTP code to clipboard.")

    return ExitCodes.SUCCESS

if __name__ == '__main__':
    sys.exit(main(parse_args()))

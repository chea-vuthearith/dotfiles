#!/usr/bin/env bash
# Opens a fresh Claude usage window on every Anthropic OAuth account.
#
# A subscription's 5-hour window starts with the first message the account
# receives and lives for 5 hours, so a tiny message at 07:00 buys a window
# that covers the working day. The message is the smallest the API accepts:
# one token in, one token out, no system prompt, no tools, no tools schema.
# Every account gets its own request, because the window is per account.
set -uo pipefail

provider=anthropic
api_url=https://api.anthropic.com/v1/messages
# Cheapest models a Claude subscription may call; the first one that is not
# rejected wins. A rejected model costs no tokens.
models=(claude-haiku-4-5 claude-haiku-5-5 claude-sonnet-4-5)

reply=$(mktemp)
trap 'rm -f "$reply"' EXIT

log() { printf '%s %s\n' "$(date -Is)" "$*"; }

body() {
  printf '{"model":"%s","max_tokens":1,"messages":[{"role":"user","content":"1"}]}' "$1"
}

# One request; prints the HTTP status, leaves the body in $reply.
call() {
  curl -sS -o "$reply" -w '%{http_code}' --max-time 30 -X POST "$api_url" \
    -H "authorization: Bearer $1" \
    -H "anthropic-version: 2023-06-01" \
    -H "anthropic-beta: oauth-2025-04-20" \
    -H "content-type: application/json" \
    -d "$(body "$2")" 2>/dev/null
}

error() { sed -n 's/.*"message":"\([^"]*\)".*/\1/p' "$reply" | head -1; }

accounts=$(omp token "$provider" --list 2>/dev/null) || {
  log "no $provider OAuth accounts"
  exit 0
}

count=$(printf '%s\n' "$accounts" | grep -c '^[0-9]\+\. ' || true)
if [ "$count" -eq 0 ]; then
  log "no $provider OAuth accounts"
  exit 0
fi

for i in $(seq 1 "$count"); do
  label=$(printf '%s\n' "$accounts" | sed -n "${i}p" | sed 's/^[0-9]\+\. *//')

  # omp re-mints an expired access token on the way out; --force-refresh only
  # matters when the token was rotated under us (401 below).
  token=$(omp token "$provider" --account "$i" --raw 2>/dev/null) || {
    log "account $i ($label): no access token"
    continue
  }

  status=""
  for model in "${models[@]}"; do
    status=$(call "$token" "$model" || true)
    [ "$status" = 400 ] || break
  done

  if [ "$status" = 401 ]; then
    # Rotated bearer: refresh the OAuth token (this is the refresh timer) and retry.
    token=$(omp token "$provider" --account "$i" --raw --force-refresh 2>/dev/null) || {
      log "account $i ($label): token refresh failed"
      continue
    }
    for model in "${models[@]}"; do
      status=$(call "$token" "$model" || true)
      [ "$status" = 400 ] || break
    done
  fi

  case "$status" in
    200) log "account $i ($label): window open" ;;
    429) log "account $i ($label): window full, it rolls over on its own" ;;
    *) log "account $i ($label): HTTP $status $(error)" ;;
  esac
done

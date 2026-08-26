#!/usr/bin/env bash
INPUT=$(cat)

ERROR=$(echo "$INPUT" | jq -r '.error // empty')
if [ "$ERROR" != "rate_limit" ]; then
  exit 0
fi

MSG=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')

RESET_TIME=$(echo "$MSG" | grep -oP '(\d{1,2}:\d{2}\s*(?:AM|PM|am|pm)?)' | head -1 | xargs)

if [ -z "$RESET_TIME" ]; then
  notify-send "Claude $HERDR_PANE_ID" "Limit reached, could not parse resume time"
  exit 0
fi

HOUR=$(echo "$RESET_TIME" | grep -oP '^\d{1,2}' | xargs)
MIN=$(echo "$RESET_TIME" | grep -oP ':(\d{2})' | head -1 | tr -d ':' | xargs)
AMPM=$(echo "$RESET_TIME" | grep -oP '(AM|PM|am|pm)' | xargs)

if [ -n "$AMPM" ]; then
  AMPM_UPPER=$(echo "$AMPM" | tr '[:lower:]' '[:upper:]')
  if [ "$AMPM_UPPER" = "PM" ] && [ "$HOUR" -ne 12 ]; then
    HOUR=$((HOUR + 12))
  elif [ "$AMPM_UPPER" = "AM" ] && [ "$HOUR" -eq 12 ]; then
    HOUR=0
  fi
fi

MIN=$((MIN + 1))
if [ "$MIN" -ge 60 ]; then
  MIN=$((MIN - 60))
  HOUR=$((HOUR + 1))
fi
if [ "$HOUR" -ge 24 ]; then
  HOUR=$((HOUR - 24))
fi

SCHEDULE_TIME=$(printf "%02d:%02d" "$HOUR" "$MIN")

echo "echo 'herdr agent prompt $HERDR_PANE_ID \"continue\"'" | at "$SCHEDULE_TIME" 2>/dev/null

notify-send "Claude $HERDR_PANE_ID" "Limit reached, will resume at $SCHEDULE_TIME"

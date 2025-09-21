#!/usr/bin/env bash

if pgrep wf-recorder >/dev/null; then
  echo 'true'
else
  echo ''
fi

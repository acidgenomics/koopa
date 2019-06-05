#!/usr/bin/env bash

# Alternate mappings for Ctrl-U/V to search the history.
bind '"^u" history-search-backward'
bind '"^v" history-search-forward'

# Fix delete key on macOS.
[[ -n "${MACOS:-}" ]] && bind '"\e[3~" delete-char'

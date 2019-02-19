#!/usr/bin/env bash

# Source global definitions.
# shellcheck source=/dev/null
[[ -f /etc/bashrc ]] && source /etc/bashrc

# Source Bash completions.
# shellcheck source=/dev/null
[[ -f /etc/profile.d/bash-completion ]] && \
    source /etc/profile.d/bash-completion
# shellcheck source=/dev/null
[[ -f /usr/local/etc/bash_completion ]] && \
    source /usr/local/etc/bash_completion

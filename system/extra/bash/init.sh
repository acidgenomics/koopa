#!/usr/bin/env bash

# shellcheck source=/dev/null
[[ -f /etc/profile ]] && source /etc/profile

# shellcheck source=/dev/null
[[ -f /etc/bashrc ]] && source /etc/bashrc

# shellcheck source=/dev/null
[[ -f /etc/profile.d/bash-completion ]] && \
    source /etc/profile.d/bash-completion

# shellcheck source=/dev/null
[[ -f /usr/local/etc/bash_completion ]] && \
    source /usr/local/etc/bash_completion

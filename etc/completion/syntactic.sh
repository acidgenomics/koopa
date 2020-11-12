#!/usr/bin/env bash

words=(
    '--prefix'
    '--recursive'
    '--strict'
)
complete -W "${words[*]}" kebab-case snake-case
words+=('--strict')
complete -W "${words[*]}" camel-case

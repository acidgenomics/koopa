#!/usr/bin/env bash

# koopa {{{1
# ==============================================================================
words=(
    "--help"
    "--version"
    "check-system"
    "header"
    "info"
    "install-dotfiles"
    "list"
    "prefix"
    "test"
    "uninstall"
    "update"
    "version"
)
complete -W "${words[*]}" koopa

# syntactic {{{1
# ==============================================================================
words=(
    "--prefix"
    "--recursive"
    "--strict"
)
complete -W "${words[*]}" kebab-case snake-case
words+=("--strict")
complete -W "${words[*]}" camel-case


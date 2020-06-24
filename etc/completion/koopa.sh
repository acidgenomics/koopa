#!/usr/bin/env bash

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

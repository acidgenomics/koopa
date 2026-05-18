#!/bin/sh
# Standalone koopa uninstall — no Python dependency.
# Use this when koopa's bootstrap Python is broken or the platform is unsupported.
set -eu

_script="$0"
if [ -L "$_script" ]; then
    _script="$(readlink -f "$_script" 2>/dev/null || \
        perl -MCwd -le 'print Cwd::abs_path shift' "$_script" 2>/dev/null)" || true
fi
_koopa_prefix="$(cd "$(dirname "$_script")" && pwd -P)"
[ -d "$_koopa_prefix" ] || exit 1

_bootstrap="${_koopa_prefix}-bootstrap"
_xdg_config="${XDG_CONFIG_HOME:-${HOME}/.config}/koopa"
_xdg_data="${XDG_DATA_HOME:-${HOME}/.local/share}/koopa"

printf 'Uninstalling koopa from: %s\n' "$_koopa_prefix" >&2

if [ -d "$_bootstrap" ]; then
    printf 'Removing bootstrap prefix.\n' >&2
    rm -rf "$_bootstrap"
fi

if [ -d "${_koopa_prefix}/etc/koopa" ]; then
    printf 'Removing config prefix.\n' >&2
    rm -rf "${_koopa_prefix}/etc/koopa"
fi

if [ -d "$_xdg_config" ]; then
    printf 'Removing %s.\n' "$_xdg_config" >&2
    rm -rf "$_xdg_config"
fi

if [ -L "$_xdg_data" ]; then
    printf 'Removing %s.\n' "$_xdg_data" >&2
    rm -f "$_xdg_data"
fi

if [ -f "/etc/profile.d/zzz-koopa.sh" ]; then
    printf 'Removing /etc/profile.d/zzz-koopa.sh.\n' >&2
    sudo rm -f "/etc/profile.d/zzz-koopa.sh"
fi

printf 'Removing %s.\n' "$_koopa_prefix" >&2
rm -rf "$_koopa_prefix"

printf 'koopa has been uninstalled.\n' >&2

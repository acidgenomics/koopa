#!/bin/csh

# Koopa activation for csh/tcsh.
# @note Updated 2026-05-01.
# @note Provides minimal activation only (PATH + environment variables).
# Full tool activation requires a function-capable shell (bash, zsh, fish).
#
# Usage:
#     1. Set KOOPA_PREFIX before sourcing:
#         setenv KOOPA_PREFIX /path/to/koopa
#
#     2. Source in your .cshrc or .tcshrc:
#         source /path/to/koopa/activate.csh

# Require KOOPA_PREFIX to be set.
if ( ! $?KOOPA_PREFIX ) then
    echo "koopa: KOOPA_PREFIX must be set before sourcing activate.csh." > /dev/stderr
    exit 1
endif

# Skip if requested.
if ( $?KOOPA_SKIP ) then
    if ( "$KOOPA_SKIP" == "1" ) exit 0
endif

# Check for interactive shell (unless forced).
if ( ! $?KOOPA_FORCE ) then
    if ( ! $?prompt ) exit 0
endif

# PATH.
if ( -d "${KOOPA_PREFIX}/bin" ) then
    setenv PATH "${KOOPA_PREFIX}/bin:${PATH}"
endif

# Bootstrap.
if ( -d "${KOOPA_PREFIX}/libexec/bootstrap/bin" ) then
    setenv PATH "${KOOPA_PREFIX}/libexec/bootstrap/bin:${PATH}"
endif

# MANPATH.
if ( $?MANPATH ) then
    setenv MANPATH "${KOOPA_PREFIX}/share/man:${MANPATH}"
else
    setenv MANPATH "${KOOPA_PREFIX}/share/man"
endif

# KOOPA_SHELL.
if ( $?tcsh ) then
    setenv KOOPA_SHELL `which tcsh`
else
    setenv KOOPA_SHELL `which csh`
endif
if ( ! $?SHELL ) then
    setenv SHELL "$KOOPA_SHELL"
endif

# Skip remaining setup in minimal mode.
if ( $?KOOPA_MINIMAL ) then
    if ( "$KOOPA_MINIMAL" == "1" ) exit 0
endif

# XDG base directories.
if ( ! $?XDG_CACHE_HOME ) setenv XDG_CACHE_HOME "${HOME}/.cache"
if ( ! $?XDG_CONFIG_DIRS ) setenv XDG_CONFIG_DIRS "/etc/xdg"
if ( ! $?XDG_CONFIG_HOME ) setenv XDG_CONFIG_HOME "${HOME}/.config"
if ( ! $?XDG_DATA_DIRS ) setenv XDG_DATA_DIRS "/usr/local/share:/usr/share"
if ( ! $?XDG_DATA_HOME ) setenv XDG_DATA_HOME "${HOME}/.local/share"
if ( ! $?XDG_STATE_HOME ) setenv XDG_STATE_HOME "${HOME}/.local/state"

# EDITOR / VISUAL.
if ( ! $?EDITOR ) then
    if ( -x "${KOOPA_PREFIX}/bin/nvim" ) then
        setenv EDITOR "${KOOPA_PREFIX}/bin/nvim"
    else
        setenv EDITOR vim
    endif
endif
setenv VISUAL "$EDITOR"

# PAGER.
if ( ! $?PAGER ) then
    if ( -x "${KOOPA_PREFIX}/bin/less" ) then
        setenv PAGER "${KOOPA_PREFIX}/bin/less -R"
    endif
endif

# MANPAGER.
if ( ! $?MANPAGER ) then
    if ( -x "${KOOPA_PREFIX}/bin/nvim" ) then
        setenv MANPAGER "${KOOPA_PREFIX}/bin/nvim +Man\!"
    endif
endif

# Color mode.
if ( ! $?KOOPA_COLOR_MODE ) setenv KOOPA_COLOR_MODE dark

# GCC colors.
if ( ! $?GCC_COLORS ) then
    setenv GCC_COLORS 'error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'
endif

# GnuPG.
if ( ! $?GPG_TTY ) then
    if ( -t 0 ) then
        setenv GPG_TTY `tty`
    endif
endif

# Aliases.
alias ..     'cd ..'
alias ...    'cd ../..'
alias ....   'cd ../../..'
alias .....  'cd ../../../..'
alias ......  'cd ../../../../..'
alias :q     exit
alias c      clear
alias e      exit
alias g      git
alias h      history
alias q      exit
alias k      koopa

if ( -x "${KOOPA_PREFIX}/bin/eza" ) then
    alias l "${KOOPA_PREFIX}/bin/eza --classify --color=auto"
else
    alias l 'ls -BFhp'
endif
alias 'l.'  'l -d .*'
alias l1    'ls -1'
alias la    'l -a'
alias ll    'l -l'

# User-defined aliases.
if ( -f "${HOME}/.aliases" ) source "${HOME}/.aliases"
if ( -f "${HOME}/.aliases-private" ) source "${HOME}/.aliases-private"
if ( -f "${HOME}/.aliases-work" ) source "${HOME}/.aliases-work"

# Final PATH additions.
if ( -d /usr/local/sbin ) then
    setenv PATH "/usr/local/sbin:${PATH}"
endif
if ( -d /usr/local/bin ) then
    setenv PATH "/usr/local/bin:${PATH}"
endif
if ( -d "${HOME}/.local/bin" ) then
    setenv PATH "${HOME}/.local/bin:${PATH}"
endif
if ( -d "${HOME}/.bin" ) then
    setenv PATH "${HOME}/.bin:${PATH}"
endif
if ( -d "${HOME}/bin" ) then
    setenv PATH "${HOME}/bin:${PATH}"
endif

#!/usr/bin/env zsh

_koopa_activate_zsh_compinit() {
    autoload -Uz compinit
    local _zcompdump="${ZDOTDIR:-${HOME:?}}/.zcompdump"
    # Newest file in koopa's central zsh completion dir (Nom[1] = newest-first,
    # N = nullglob so it expands to nothing if dir is empty). Resolves through
    # symlinks for the mtime test.
    local _newest
    _newest=("${KOOPA_PREFIX:?}/share/zsh/site-functions"/*(Nom[1]N))
    # Fast path (compinit -C, reuse dump) ONLY when the dump is recent AND no
    # completion file is newer than it; otherwise do a full compinit to rebuild.
    # This ensures a newly-linked completion (e.g. after `koopa install <app>`)
    # is picked up in the very next zsh session rather than waiting up to 24h.
    if [[ -n ${_zcompdump}(#qN.mh-24) ]] \
        && { [[ -z "$_newest" ]] || [[ ! "$_newest" -nt "$_zcompdump" ]]; }
    then
        compinit -C 2>/dev/null
    else
        compinit 2>/dev/null
    fi
    return 0
}

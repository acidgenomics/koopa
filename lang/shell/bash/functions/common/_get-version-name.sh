#!/usr/bin/env bash

__koopa_get_version_name() {
    # """
    # Match a desired program name to corresponding to dependency to
    # run with a version argument.
    # @note Updated 2022-03-25.
    # """
    local name
    koopa_assert_has_args_eq "$#" 1
    name="$(koopa_basename "${1:?}")"
    case "$name" in
        'aspera-connect')
            name='ascp'
            ;;
        'aws-cli')
            name='aws'
            ;;
        'azure-cli')
            name='az'
            ;;
        'bcbio-nextgen')
            name='bcbio_nextgen.py'
            ;;
        'binutils')
            # Checking against 'ld' doesn't work on macOS with Homebrew.
            name='dlltool'
            ;;
        'coreutils')
            name='env'
            ;;
        'du-dust')
            name='dust'
            ;;
        'fd-find')
            name='fd'
            ;;
        'findutils')
            name='find'
            ;;
        'gdal')
            name='gdal-config'
            ;;
        'geos')
            name='geos-config'
            ;;
        'gnupg')
            name='gpg'
            ;;
        'google-cloud-sdk')
            name='gcloud'
            ;;
        'gsl')
            name='gsl-config'
            ;;
        'homebrew')
            name='brew'
            ;;
        'icu')
            name='icu-config'
            ;;
        'llvm')
            name='llvm-config'
            ;;
        'man-db')
            name='man'
            ;;
        'ncurses')
            name='ncurses6-config'
            ;;
        'neovim')
            name='nvim'
            ;;
        'openssh')
            name='ssh'
            ;;
        'password-store')
            name='pass'
            ;;
        'pcre2')
            name='pcre2-config'
            ;;
        'pip')
            name='pip3'
            ;;
        'python')
            name='python3'
            ;;
        'ranger-fm')
            name='ranger'
            ;;
        'ripgrep')
            name='rg'
            ;;
        'ripgrep-all')
            name='rga'
            ;;
        'rust')
            name='rustc'
            ;;
        'sqlite')
            name='sqlite3'
            ;;
        'subversion')
            name='svn'
            ;;
        'tealdeer')
            name='tldr'
            ;;
        'texinfo')
            # TeX Live install can mask this on macOS.
            name='texi2any'
            ;;
        'the-silver-searcher')
            name='ag'
            ;;
    esac
    koopa_print "$name"
    return 0
}

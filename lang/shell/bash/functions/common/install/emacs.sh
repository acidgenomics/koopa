#!/usr/bin/env bash

# FIXME Failing to build on macOS:
#ld: symbol(s) not found for architecture x86_64
#clang: error: linker command failed with exit code 1 (use -v to see invocation)
#make[1]: *** [Makefile:368: etags] Error 1
#ld: warning: ignoring file ../lib/libgnu.a, building for macOS-x86_64 but attempting to link with file built for unknown-unsupported file format ( 0x21 0x3C 0x61 0x72 0x63 0x68 0x3E 0x0A 0x2F 0x20 0x20 0x20 0x20 0x20 0x20 0x20 )
#Undefined symbols for architecture x86_64:
#  "_c_isalnum", referenced from:
#      _Asm_labels in ctags-8ff984.o
#      _Cobol_paragraphs in ctags-8ff984.o
#      _Erlang_functions in ctags-8ff984.o
#      _Perl_functions in ctags-8ff984.o
#      _Prolog_functions in ctags-8ff984.o
# [...]
#ld: symbol(s) not found for architecture x86_64
#clang: error: linker command failed with exit code 1 (use -v to see invocation)
#make[1]: *** [Makefile:375: ctags] Error 1
#make[1]: Leaving directory '/private/var/folders/l1/8y8sjzmn15v49jgrqglghcfr0000gn/T/koopa-501-20210505-101830-U2nZJYYypo/emacs-27.2/lib-src'
#make: *** [Makefile:411: lib-src] Error 2

koopa::install_emacs() { # {{{1
    local conf_args
    if koopa::is_macos
    then
        conf_args=(
            '--disable-silent-rules'
            '--with-gnutls'
            '--with-modules'
            '--with-xml2'
            '--without-dbus'
            '--without-imagemagick'
            '--without-ns'
            '--without-x'
        )
    else
        conf_args=(
            '--with-x-toolkit=no'
            '--with-xpm=no'
        )
    fi
    koopa::install_gnu_app \
        --name='emacs' \
        --name-fancy='Emacs' \
        "${conf_args[@]}"
        "$@"
}

koopa::update_emacs() { # {{{1
    # """
    # Update Emacs.
    # @note Updated 2020-11-25.
    # """
    koopa::assert_has_no_args "$#"
    if ! koopa::is_installed emacs
    then
        koopa::alert_note 'Emacs is not installed.'
        return 0
    fi
    if koopa::is_spacemacs_installed
    then
        koopa:::update_spacemacs
    elif koopa::is_doom_emacs_installed
    then
        koopa:::update_doom_emacs
    else
        koopa::alert_note 'Emacs configuration cannot be updated.'
        return 0
    fi
    return 0
}

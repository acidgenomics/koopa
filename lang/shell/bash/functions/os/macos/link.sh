#!/usr/bin/env bash

# FIXME These links currently don't have group write permissions.
# Need to rethink our linker here.

# FIXME Need to add support for (see common/locate-wrappers.sh for details):
# - aspera_connect (ascp)
# - gnupg (gpg, gpg_agent, gpgconf)

# FIXME Consider putting '/Library/TeX/texbin/tlmgr' in sbin.

# FIXME Add support for: /Applications/Little Snitch.app/Contents/Components/littlesnitch

# FIXME Need to link components from:
#        koopa_activate_homebrew_opt_prefix \
#            'bc' \
#            'curl' \
#            'gnu-getopt' \
#            'ruby' \
#            'texinfo'
#        koopa_activate_homebrew_opt_libexec_prefix \
#            'man-db'
#        koopa_activate_homebrew_opt_gnu_prefix \
#            'coreutils' \
#            'findutils' \
#            'gnu-sed' \
#            'gnu-tar' \
#            'gnu-which' \
#            'grep' \
#            'make'

koopa_macos_link_bbedit() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        'bbedit'
    return 0
}

koopa_macos_link_emacs() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Applications/Emacs.app/Contents/MacOS/Emacs' \
        'emacs'
    return 0
}

koopa_macos_link_google_cloud_sdk() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        "$(koopa_homebrew_prefix)/Caskroom/google-cloud-sdk/latest/\
google-cloud-sdk/bin/gcloud" \
        'gcloud'
    return 0
}

koopa_macos_link_julia() { # {{{1
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [julia_prefix]="$(koopa_macos_julia_prefix)"
        [koopa_prefix]="$(koopa_koopa_prefix)"
    )
    koopa_link_in_bin \
        "${dict[julia_prefix]}/bin/julia" \
        'julia'
    return 0
}

koopa_macos_link_r() { # {{{1
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [r_prefix]="$(koopa_macos_r_prefix)"
    )
    koopa_link_in_bin \
        "${dict[r_prefix]}/bin/R" 'R' \
        "${dict[r_prefix]}/bin/Rscript" 'Rscript'
    return 0
}

# FIXME Need to add a corresponding unlinker here.
koopa_macos_link_tex() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Library/TeX/texbin/tex' \
        'tex'
    return 0
}

koopa_macos_link_visual_studio_code() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' \
        'code'
    return 0
}

koopa_macos_unlink_bbedit() { # {{{1
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin 'bbedit'
    return 0
}

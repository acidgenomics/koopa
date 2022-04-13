#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Bash.
    # @note Updated 2022-04-13.
    #
    # @section Applying patches:
    #
    # Alternatively, can pipe curl call directly to 'patch -p0'.
    # https://stackoverflow.com/questions/14282617
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bash.rb
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'patch'
    declare -A app=(
        [curl]="$(koopa_locate_curl)"
        [cut]="$(koopa_locate_cut)"
        [make]="$(koopa_locate_make)"
        [patch]="$(koopa_locate_patch)"
        [tr]="$(koopa_locate_tr)"
    )
    declare -A dict=(
        [bin_prefix]="$(koopa_bin_prefix)"
        [gnu_mirror]="$(koopa_gnu_mirror_url)"
        [jobs]="$(koopa_cpu_count)"
        [link_in_bin]="${INSTALL_LINK_IN_BIN:?}"
        [name]='bash'
        [patch_prefix]='patches'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_ver]="$(koopa_major_minor_version "${dict[version]}")"
    dict[patch_base_url]="https://ftp.gnu.org/gnu/${dict[name]}/\
${dict[name]}-${dict[maj_min_ver]}-patches"
    dict[n_patches]="$( \
        koopa_major_minor_patch_version "${dict[version]}" \
        | "${app[cut]}" -d '.' -f '3' \
    )"
    dict[file]="${dict[name]}-${dict[maj_min_ver]}.tar.gz"
    dict[url]="${dict[gnu_mirror]}/${dict[name]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[maj_min_ver]}"
    # Apply patches, if necessary.
    if [[ "${dict[n_patches]}" -gt 0 ]]
    then
        koopa_alert "$(koopa_ngettext \
            --prefix='Applying ' \
            --num="${dict[n_patches]}" \
            --msg1='patch' \
            --msg2='patches' \
            --suffix=" from '${dict[patch_base_url]}'." \
        )"
        # mmv_tr: trimmed major minor version.
        dict[mmv_tr]="$( \
            koopa_print "${dict[maj_min_ver]}" \
            | "${app[tr]}" --delete '.' \
        )"
        dict[patch_range]="$(printf '%03d-%03d' '1' "${dict[n_patches]}")"
        dict[patch_request_urls]="${dict[patch_base_url]}/\
${dict[name]}${dict[mmv_tr]}-[${dict[patch_range]}]"
        koopa_mkdir "${dict[patch_prefix]}"
        (
            koopa_cd "${dict[patch_prefix]}"
            "${app[curl]}" "${dict[patch_request_urls]}" -O
            koopa_cd ..
            for file in "${dict[patch_prefix]}/"*
            do
                "${app[patch]}" -p0 --ignore-whitespace --input="$file"
            done
        )
    fi
    conf_args=("--prefix=${dict[prefix]}")
    if koopa_is_alpine
    then
        # musl does not implement brk/sbrk (they simply return -ENOMEM).
        # Otherwise will see this error:
        # xmalloc: locale.c:81: cannot allocate 18 bytes (0 bytes allocated)
        conf_args+=('--without-bash-malloc')
    elif koopa_is_macos
    then
        cflags=(
            # When built with 'SSH_SOURCE_BASHRC', bash will source '~/.bashrc'
            # when it's non-interactively from sshd. This allows the user to set
            # environment variables prior to running the command (e.g. 'PATH').
            # The '/bin/bash' that ships with macOS defines this, and without
            # it, some things (e.g. git+ssh) will break if the user sets their
            # default shell to Homebrew's bash instead of '/bin/bash'.
            '-DSSH_SOURCE_BASHRC'
            # Work around configure issues with Xcode 12.
            # https://savannah.gnu.org/patch/index.php?9991
            # Safe to remove for version 5.1.
            # > '-Wno-implicit-function-declaration'
        )
        conf_args+=("CFLAGS=${cflags[*]}")
    fi
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    # > "${app[make]}" test
    "${app[make]}" install
    if [[ "${dict[link_in_bin]}" -eq 1 ]]
    then
        koopa_enable_shell_for_all_users "${dict[bin_prefix]}/${dict[name]}"
    fi
    return 0
}

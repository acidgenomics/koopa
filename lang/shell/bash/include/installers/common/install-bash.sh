#!/usr/bin/env bash

koopa:::install_bash() { # {{{1
    # """
    # Install Bash.
    # @note Updated 2022-02-11.
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
    koopa::assert_has_no_args "$#"
    declare -A app=(
        [curl]="$(koopa::locate_curl)"
        [cut]="$(koopa::locate_cut)"
        [make]="$(koopa::locate_make)"
        [patch]="$(koopa::locate_patch)"
        [tr]="$(koopa::locate_tr)"
    )
    declare -A dict=(
        [gnu_mirror]="$(koopa::gnu_mirror_url)"
        [jobs]="$(koopa::cpu_count)"
        [link_app]="${INSTALL_LINK_APP:?}"
        [name]='bash'
        [patch_prefix]='patches'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[maj_min_ver]="$(koopa::major_minor_version "${dict[version]}")"
    dict[patch_base_url]="https://ftp.gnu.org/gnu/${dict[name]}/\
${dict[name]}-${dict[maj_min_ver]}-patches"
    dict[n_patches]="$( \
        koopa::major_minor_patch_version "${dict[version]}" \
        | "${app[cut]}" --delimiter='.' --fields='3' \
    )"
    dict[file]="${dict[name]}-${dict[maj_min_ver]}.tar.gz"
    dict[url]="${dict[gnu_mirror]}/${dict[name]}/${dict[file]}"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::cd "${dict[name]}-${dict[maj_min_ver]}"
    # Apply patches, if necessary.
    if [[ "${dict[n_patches]}" -gt 0 ]]
    then
        koopa::alert "$(koopa::ngettext \
            --prefix='Applying ' \
            --num="${dict[n_patches]}" \
            --msg1='patch' \
            --msg2='patches' \
            --suffix="from '${dict[patch_base_url]}'." \
        )"
        # mmv_tr: trimmed major minor version.
        dict[mmv_tr]="$( \
            koopa::print "${dict[maj_min_ver]}" \
            | "${app[tr]}" --delete '.' \
        )"
        dict[patch_range]="$(printf '%03d-%03d' '1' "${dict[n_patches]}")"
        dict[patch_request_urls]="${dict[patch_base_url]}/\
${dict[name]}${dict[mmv_tr]}-[${dict[patch_range]}]"
        koopa::mkdir "${dict[patch_prefix]}"
        (
            koopa::cd "${dict[patch_prefix]}"
            "${app[curl]}" "${dict[patch_request_urls]}" -O
            koopa::cd ..
            for file in "${dict[patch_prefix]}/"*
            do
                "${app[patch]}" -p0 --ignore-whitespace --input="$file"
            done
        )
    fi
    conf_args=("--prefix=${dict[prefix]}")
    if koopa::is_alpine
    then
        # musl does not implement brk/sbrk (they simply return -ENOMEM).
        # Otherwise will see this error:
        # xmalloc: locale.c:81: cannot allocate 18 bytes (0 bytes allocated)
        conf_args+=('--without-bash-malloc')
    elif koopa::is_macos
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
    if [[ "${dict[link_app]}" -eq 1 ]]
    then
        koopa::enable_shell_for_all_users "${dict[name]}"
    fi
    return 0
}

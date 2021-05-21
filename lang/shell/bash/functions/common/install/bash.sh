#!/usr/bin/env bash

koopa::install_bash() { # {{{1
    koopa::install_app \
        --name='bash' \
        --name-fancy='Bash' \
        "$@"
}

koopa:::install_bash() { # {{{1
    # """
    # Install Bash.
    # @note Updated 2021-05-21.
    # @seealso
    # https://github.com/Homebrew/homebrew-core/blob/master/Formula/bash.rb
    # """
    local base_url cflags conf_args curl cut file gnu_mirror jobs link_app \
        make minor_version mv_tr patch patches range request tr url version
    curl="$(koopa::locate_curl)"
    cut="$(koopa::locate_cut)"
    gnu_mirror="$(koopa::gnu_mirror_url)"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    patch="$(koopa::locate_patch)"
    tr="$(koopa::locate_tr)"
    link_app="${INSTALL_LINK_APP:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='bash'
    minor_version="$(koopa::major_minor_version "$version")"
    file="${name}-${minor_version}.tar.gz"
    url="${gnu_mirror}/${name}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${minor_version}"
    # Apply patches. 
    patches="$(koopa::print "$version" | "$cut" -d '.' -f 3)"
    koopa::mkdir 'patches'
    (
        koopa::cd 'patches'
        # Note that GNU mirror doesn't seem to work correctly here.
        base_url="https://ftp.gnu.org/gnu/${name}/\
${name}-${minor_version}-patches"
        mv_tr="$(koopa::print "$minor_version" | "$tr" -d '.')"
        range="$(printf '%03d-%03d' '1' "$patches")"
        request="${base_url}/${name}${mv_tr}-[${range}]"
        "$curl" "$request" -O
        koopa::cd ..
        for file in 'patches/'*
        do
            koopa::alert "Applying patch '${file}'."
            # Alternatively, can pipe curl call directly to 'patch -p0'.
            # https://stackoverflow.com/questions/14282617
            "$patch" -p0 --ignore-whitespace --input="$file"
        done
    )
    conf_args=("--prefix=${prefix}")
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
    "$make" --jobs="$jobs"
    # > "$make" test
    "$make" install
    [[ "${link_app:-0}" -eq 1 ]] && koopa::enable_shell "$name"
    return 0
}

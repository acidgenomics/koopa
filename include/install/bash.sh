#!/usr/bin/env bash

# """
# @seealso
# https://github.com/Homebrew/homebrew-core/blob/master/Formula/bash.rb
# """

gnu_mirror="${INSTALL_GNU_MIRROR:?}"
jobs="${INSTALL_JOBS:?}"
name="${INSTALL_NAME:?}"
version="${INSTALL_VERSION:?}"

minor_version="$(koopa::major_minor_version "$version")"
file="${name}-${minor_version}.tar.gz"
url="${gnu_mirror}/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${minor_version}"
# Apply patches. 
patches="$(koopa::print "$version" | cut -d '.' -f 3)"
koopa::mkdir patches
(
    koopa::cd patches
    # Note that GNU mirror doesn't seem to work correctly here.
    base_url="https://ftp.gnu.org/gnu/${name}/${name}-${minor_version}-patches"
    mv_tr="$(koopa::print "$minor_version" | tr -d '.')"
    range="$(printf '%03d-%03d' '1' "$patches")"
    request="${base_url}/${name}${mv_tr}-[${range}]"
    curl "$request" -O
    koopa::cd ..
    for file in 'patches/'*
    do
        koopa::alert "Applying patch '${file}'."
        # Alternatively, can pipe curl call directly to 'patch -p0'.
        # https://stackoverflow.com/questions/14282617
        patch -p0 --ignore-whitespace --input="$file"
    done
)
flags=('--prefix' "$prefix")
if koopa::is_alpine
then
    # musl does not implement brk/sbrk (they simply return -ENOMEM).
    # Otherwise will see this error:
    # bash: xmalloc: locale.c:81: cannot allocate 18 bytes (0 bytes allocated)
    flags+=('--without-bash-malloc')
elif koopa::is_macos
then
    cflags=(
        # When built with SSH_SOURCE_BASHRC, bash will source ~/.bashrc when
        # it's non-interactively from sshd. This allows the user to set
        # environment variables prior to running the command (e.g. PATH). The
        # /bin/bash that ships with macOS defines this, and without it, some
        # things (e.g. git+ssh) will break if the user sets their default shell
        # to Homebrew's bash instead of /bin/bash.
        '-DSSH_SOURCE_BASHRC'
        # Work around configure issues with Xcode 12.
        # https://savannah.gnu.org/patch/index.php?9991
        # Remove for version 5.1.
        '-Wno-implicit-function-declaration'
    )
    flags+=("CFLAGS=${cflags[*]}")
fi
./configure "${flags[@]}"
make --jobs="$jobs"
# > make test
make install
if [[ "${link_app:-0}" -eq 1 ]]
then
    koopa::enable_shell "$name"
fi

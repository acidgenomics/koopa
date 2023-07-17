#!/usr/bin/env bash

# FIXME Need to use RUSTFLAGS to pass these correctly.
# https://doc.rust-lang.org/cargo/reference/environment-variables.html#environment-variables-cargo-reads
# https://doc.rust-lang.org/cargo/reference/config.html#buildrustflags
# https://github.com/Homebrew/brew/blob/7ee069ef47e4ea7c2bff705847e9ef647b4e5da3/Library/Homebrew/formula.rb#L1555
# https://internals.rust-lang.org/t/compiling-rustc-with-non-standard-flags/8950/6

# FIXME Hitting this build error on Linux:
#1" "-nodefaultlibs"
#  = note: /usr/bin/ld: cannot find -lxcb: No such file or directory
#          /usr/bin/ld: cannot find -lxcb-render: No such file or directory
#          /usr/bin/ld: cannot find -lxcb-shape: No such file or directory
#          /usr/bin/ld: cannot find -lxcb-xfixes: No such file or directory
#          collect2: error: ld returned 1 exit status

main() {
    # """
    # Install jless.
    # @note Updated 2023-07-17.
    #
    # @seealso
    # - https://formulae.brew.sh/formula/jless
    # """
    if koopa_is_linux
    then
        koopa_activate_app --build-only 'python3.11'
        koopa_activate_app \
            'xorg-xorgproto' \
            'xorg-libxau' \
            'xorg-libxdmcp' \
            'xorg-libxcb'
        RUSTFLAGS="${LDFLAGS:-}"
        export RUSTFLAGS
    fi
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='jless'
}

#!/usr/bin/env bash

# FIXME Failing to build with Rust 1.80 due to libgit2 issue it appears.
#
# https://github.com/rust-lang/git2-rs/blob/master/libgit2-sys/build.rs
#
# cargo:warning=failed to probe system libgit2: Failed to run `PKG_CONFIG_ALLOW_SYSTEM_CFLAGS="1" PKG_CONFIG_ALLOW_SYSTEM_LIBS="1" PKG_CONFIG_PATH="/opt/koopa/app/libgit2/1.8.1/lib/pkgconfig" "pkg-config" "--libs" "--cflags" "libgit2" "libgit2 >= 1.8.1" "libgit2 < 1.9.0"`: No such file or directory (os error 2)
#
# https://github.com/eza-community/eza/issues/1072

main() {
    # """
    # Install eza.
    # @note Updated 2024-07-27.
    # """
    koopa_activate_app 'libgit2'
    export LIBGIT2_NO_VENDOR=1
    koopa_install_rust_package
    return 0
}

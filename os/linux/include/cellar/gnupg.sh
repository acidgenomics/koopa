#!/usr/bin/env bash
# shellcheck disable=SC2154

case "$version" in
    2.2.19)
        # 2019-12-07
        libgpg_error_version="1.37"
        libgcrypt_version="1.8.5"
        libassuan_version="2.5.3"
        libksba_version="1.3.5"
        npth_version="1.6"
        pinentry_version="1.1.0"
        ;;
    *)
        _koopa_stop "Unsupported GnuPG version."
        ;;
esac

# Download GnuPG release signing keys.
if _koopa_is_installed gpg-agent
then
    gpg --list-keys
    gpg --keyserver hkp://keyserver.ubuntu.com:80 \
        --recv-keys 249B39D24F25E3B6 \
                    04376F3EE0856959 \
                    2071B08A33BD3F06 \
                    8A861B1C7EFD60D9
fi

# shellcheck disable=SC2034
gcrypt_url="https://gnupg.org/ftp/gcrypt"

# Install dependencies.
_koopa_install_cellar \
    --name="libgpg-error" \
    --version="$libgpg_error_version" \
    --script-name="gnupg-gcrypt" \
    "$@"
_koopa_install_cellar \
    --name="libgcrypt" \
    --version="$libgcrypt_version" \
    --script-name="gnupg-gcrypt" \
    "$@"
_koopa_install_cellar \
    --name="libassuan" \
    --version="$libassuan_version" \
    --script-name="gnupg-gcrypt" \
    "$@"
_koopa_install_cellar \
    --name="libksba" \
    --version="$libksba_version" \
    --script-name="gnupg-gcrypt" \
    "$@"
_koopa_install_cellar \
    --name="npth" \
    --version="$npth_version" \
    --script-name="gnupg-gcrypt" \
    "$@"
_koopa_install_cellar \
    --name="pinentry" \
    --version="$pinentry_version" \
    --script-name="gnupg-pinentry" \
    "$@"

# Now ready to install GnuPG.
_koopa_install_cellar \
    --name="gnupg" \
    --version="$version" \
    --script-name="gnupg-gcrypt" \
    "$@"

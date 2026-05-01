#!/usr/bin/env bash

main() {
    # """
    # Install uv.
    # Updated 2026-02-06.
    #
    # See also:
    # - https://docs.astral.sh/uv/reference/installer/
    # """
    local -A dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']='https://astral.sh/uv/install.sh'
    _koopa_download "${dict['url']}"
    dict['script']="$(_koopa_realpath "$(_koopa_basename "${dict['url']}")")"
    _koopa_chmod +x "${dict['script']}"
    export UV_NO_MODIFY_PATH=1
    export UV_PRINT_VERBOSE=1
    export UV_UNMANAGED_INSTALL="${dict['prefix']}/bin"
    _koopa_print_env
    "${dict['script']}"
    return 0
}

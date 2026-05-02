#!/usr/bin/env bash

main() {
    # """
    # Install PowerShell.
    # @note Updated 2026-05-01.
    #
    # @seealso
    # - https://github.com/PowerShell/PowerShell/
    # - https://learn.microsoft.com/en-us/powershell/scripting/install/
    #     installing-powershell-on-linux
    # - https://learn.microsoft.com/en-us/powershell/scripting/install/
    #     installing-powershell-on-macos
    # """
    local -A dict
    dict['arch']="$(_koopa_arch2)"
    dict['os']="$(_koopa_os_id)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if _koopa_is_macos
    then
        dict['platform']="osx-${dict['arch']}"
        dict['ext']='tar.gz'
    elif _koopa_is_linux
    then
        dict['platform']="linux-${dict['arch']}"
        dict['ext']='tar.gz'
    else
        _koopa_stop "Unsupported platform: ${dict['os']}."
    fi
    dict['url']="https://github.com/PowerShell/PowerShell/releases/download/\
v${dict['version']}/powershell-${dict['version']}-${dict['platform']}.${dict['ext']}"
    _koopa_download "${dict['url']}"
    _koopa_extract \
        "$(_koopa_basename "${dict['url']}")" \
        "${dict['prefix']}"
    _koopa_chmod 'a+x' "${dict['prefix']}/pwsh"
    _koopa_mkdir "${dict['prefix']}/bin"
    _koopa_ln "${dict['prefix']}/pwsh" "${dict['prefix']}/bin/pwsh"
    return 0
}

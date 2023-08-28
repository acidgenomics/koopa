#!/usr/bin/env bash

# FIXME Need to support '--ldflags' here.
# FIXME Need to support '--url' here.
# FIXME Allow the user to change bin-name? Default to the app name.
# FIXME Need to support some type of 'bin' argument here? What about just
# '-o' passthrough?

main() {
    # """
    # Install a Go package.
    # @note Updated 2023-08-28.
    # """
    local -A app dict
    local -a build_args pos
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['bin_name']=''
    dict['ldflags']=''
    dict['url']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key value pairs --------------------------------------------------
            '--bin-name='*)
                dict['bin_name']="${1#*=}"
                shift 1
                ;;
            '--bin-name')
                dict['bin_name']="${2:?}"
                shift 2
                ;;
            '--ldflags='*)
                dict['ldflags']="${1#*=}"
                shift 1
                ;;
            '--ldflags')
                dict['ldflags']="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    [[ -z "${dict['bin_name']}" ]] && dict['bin_name']="${dict['name']}"
    if [[ -n "${dict['ldflags']}" ]]
    then
        build_args+=('-ldflags' "${dict['ldflags']}")
    fi
    build_args+=('-o' "${dict['prefix']}/bin/${dict['bin_name']}")
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    koopa_dl 'go build args' "${build_args[*]}"
    "${app['go']}" build "${build_args[@]}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

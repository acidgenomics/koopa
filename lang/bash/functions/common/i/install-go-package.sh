#!/usr/bin/env bash

koopa_install_go_package() {
    # """
    # Install a Go package.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://pkg.go.dev/cmd/go#hdr-Module_maintenance
    # - https://stackoverflow.com/questions/66518161/
    # """
    local -A app dict
    local -a build_args
    koopa_assert_is_install_subshell
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['bin_name']=''
    dict['build_cmd']=''
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['ldflags']=''
    dict['mod']=''
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['tags']=''
    dict['url']=''
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bin-name='*)
                dict['bin_name']="${1#*=}"
                shift 1
                ;;
            '--bin-name')
                dict['bin_name']="${2:?}"
                shift 2
                ;;
            '--build-cmd='*)
                dict['build_cmd']="${1#*=}"
                shift 1
                ;;
            '--build-cmd')
                dict['build_cmd']="${2:?}"
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
            '--mod='*)
                dict['mod']="${1#*=}"
                shift 1
                ;;
            '--mod')
                dict['mod']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--tags='*)
                dict['tags']="${1#*=}"
                shift 1
                ;;
            '--tags')
                dict['tags']="${2:?}"
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
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--mod-init')
                bool['mod_init']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}" \
        '--version' "${dict['version']}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    [[ -z "${dict['bin_name']}" ]] && dict['bin_name']="${dict['name']}"
    if [[ -n "${dict['ldflags']}" ]]
    then
        build_args+=('-ldflags' "${dict['ldflags']}")
    fi
    if [[ -n "${dict['mod']}" ]]
    then
        build_args+=('-mod' "${dict['mod']}")
    fi
    if [[ -n "${dict['tags']}" ]]
    then
        build_args+=('-tags' "${dict['tags']}")
    fi
    build_args+=('-o' "${dict['prefix']}/bin/${dict['bin_name']}")
    if [[ -n "${dict['build_cmd']}" ]]
    then
        build_args+=("${dict['build_cmd']}")
    fi
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    koopa_print_env
    koopa_dl 'go build args' "${build_args[*]}"
    "${app['go']}" build "${build_args[@]}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

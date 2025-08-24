#!/usr/bin/env bash

koopa_git_clone() {
    # """
    # Quietly clone a git repository.
    # @note Updated 2025-08-24.
    #
    # @seealso
    # - https://github.blog/2020-12-21-get-up-to-speed-with-partial-clone-
    #     and-shallow-clone/
    # - https://stackoverflow.com/questions/8932389/
    # - https://devconnected.com/how-to-checkout-git-tags/
    # """
    local -A app dict
    local -a clone_args
    koopa_assert_has_args "$#"
    if koopa_is_install_subshell
    then
        app['git']="$(koopa_locate_git --only-system)"
    else
        app['git']="$(koopa_locate_git --allow-system)"
    fi
    koopa_assert_is_executable "${app[@]}"
    dict['branch']=''
    dict['commit']=''
    dict['prefix']=''
    dict['tag']=''
    dict['url']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--branch='*)
                dict['branch']="${1#*=}"
                shift 1
                ;;
            '--branch')
                dict['branch']="${2:?}"
                shift 2
                ;;
            '--commit='*)
                dict['commit']="${1#*=}"
                shift 1
                ;;
            '--commit')
                dict['commit']="${2:?}"
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
            '--tag='*)
                dict['tag']="${1#*=}"
                shift 1
                ;;
            '--tag')
                dict['tag']="${2:?}"
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
    koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}"
    if [[ -d "${dict['prefix']}" ]]
    then
        koopa_rm "${dict['prefix']}"
    fi
    # Check if user has sufficient permissions.
    if koopa_str_detect_fixed \
        --string="${dict['url']}" \
        --pattern='git@github.com'
    then
        koopa_assert_is_github_ssh_enabled
    elif koopa_str_detect_fixed \
        --string="${dict['url']}" \
        --pattern='git@gitlab.com'
    then
        koopa_assert_is_gitlab_ssh_enabled
    fi
    clone_args=(
        '--quiet'
        # > '--recursive'
    )
    if [[ -n "${dict['branch']}" ]]
    then
        clone_args+=(
            # Shallow clone.
            '--depth=1'
            '--single-branch'
            "--branch=${dict['branch']}"
        )
    else
        clone_args+=(
            # Use blobless clone.
            '--filter=blob:none'
            # Or use treeless clone (not recommended).
            # > '--filter=tree:0'
        )
    fi
    clone_args+=("${dict['url']}" "${dict['prefix']}")
    "${app['git']}" clone "${clone_args[@]}"
    if [[ -n "${dict['commit']}" ]]
    then
        (
            koopa_cd "${dict['prefix']}"
            "${app['git']}" checkout --quiet "${dict['commit']}"
        )
    elif [[ -n "${dict['tag']}" ]]
    then
        (
            koopa_cd "${dict['prefix']}"
            "${app['git']}" fetch --quiet --tags
            # This will put repo into a detached HEAD state.
            "${app['git']}" checkout --quiet "tags/${dict['tag']}"
        )
    fi
    return 0
}

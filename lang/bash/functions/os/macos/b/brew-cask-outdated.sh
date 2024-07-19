#!/usr/bin/env bash

koopa_macos_brew_cask_outdated() {
    # """
    # List outdated Homebrew casks.
    # @note Updated 2024-07-17.
    #
    # Need help with capturing output:
    # - https://stackoverflow.com/questions/58344963/
    # - https://unix.stackexchange.com/questions/253101/
    #
    # Syntax changed from 'brew cask outdated' to 'brew outdated --cask' in
    # 2020-09.
    #
    # @seealso
    # - brew leaves
    # - brew deps --installed --tree
    # - brew list --versions
    # - brew info
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['brew']="$(koopa_locate_brew)"
    app['cut']="$(koopa_locate_cut --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    # Whether we want to keep unversioned 'latest' casks returned with
    # '--greedy'. This tends to include font casks and the Google Cloud SDK,
    # which are annoying to have reinstall with each update, so disabling
    # here by default.
    dict['keep_latest']=0
    # This approach keeps the version information, which we can parse.
    dict['tmp_file']="$(koopa_tmp_file)"
    script -q "${dict['tmp_file']}" \
        "${app['brew']}" outdated --cask --greedy >/dev/null
    if [[ "${dict['keep_latest']}" -eq 1 ]]
    then
        dict['str']="$("${app['cut']}" -d ' ' -f '1' < "${dict['tmp_file']}")"
    else
        dict['str']="$( \
            koopa_grep \
                --file="${dict['tmp_file']}" \
                --fixed \
                --invert-match \
                --pattern='(latest)' \
            | "${app['cut']}" -d ' ' -f '1' \
        )"
    fi
    koopa_rm "${dict['tmp_file']}"
    [[ -n "${dict['str']}" ]] || return 0
    koopa_print "${dict['str']}"
    return 0
}

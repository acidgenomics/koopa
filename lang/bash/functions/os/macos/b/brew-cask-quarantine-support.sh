#!/usr/bin/env bash

koopa_macos_brew_cask_quarantine_support() {
    # """
    # Check Homebrew cask quarantine support.
    # @note Updated 2025-05-05.
    #
    # @seealso
    # - https://github.com/orgs/Homebrew/discussions/5482
    # """
    local -A app dict
    app['brew']="$(koopa_locate_brew)"
    app['swift']="$(koopa_locate_swift)"
    koopa_assert_is_executable "${app[@]}"
    dict['repo']="$("${app['brew']}" --repo)"
    koopa_assert_is_dir "${dict['repo']}"
    dict['file']="${dict['repo']}/Library/Homebrew/cask/utils/quarantine.swift"
    koopa_assert_is_file "${dict['file']}"
    koopa_alert "Running swift script at '${dict['file']}'."
    "${app['swift']}" "${dict['file']}"
    return 0
}

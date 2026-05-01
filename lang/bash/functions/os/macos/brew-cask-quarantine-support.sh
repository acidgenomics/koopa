#!/usr/bin/env bash

_koopa_macos_brew_cask_quarantine_support() {
    # """
    # Check Homebrew cask quarantine support.
    # @note Updated 2025-05-05.
    #
    # @seealso
    # - https://github.com/orgs/Homebrew/discussions/5482
    # """
    local -A app dict
    app['brew']="$(_koopa_locate_brew)"
    app['swift']="$(_koopa_locate_swift)"
    _koopa_assert_is_executable "${app[@]}"
    dict['repo']="$("${app['brew']}" --repo)"
    _koopa_assert_is_dir "${dict['repo']}"
    dict['file']="${dict['repo']}/Library/Homebrew/cask/utils/quarantine.swift"
    _koopa_assert_is_file "${dict['file']}"
    _koopa_alert "Running swift script at '${dict['file']}'."
    "${app['swift']}" "${dict['file']}"
    return 0
}

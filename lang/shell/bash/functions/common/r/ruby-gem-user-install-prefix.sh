#!/usr/bin/env bash

koopa_ruby_gem_user_install_prefix() {
    # """
    # Ruby gem '--user-install' prefix.
    # @note Updated 2023-02-17.
    #
    # @seealso
    # - https://guides.rubygems.org/faqs/
    # """
    local app dict
    declare -A app dict
    app['ruby']="$(koopa_locate_ruby)"
    [[ -x "${app['ruby']}" ]] || return 1
    dict['str']="$("${app['ruby']}" -r rubygems -e 'puts Gem.user_dir')"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

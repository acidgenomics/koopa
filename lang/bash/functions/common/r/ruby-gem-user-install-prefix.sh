#!/usr/bin/env bash

koopa_ruby_gem_user_install_prefix() {
    # """
    # Ruby gem '--user-install' prefix.
    # @note Updated 2023-02-17.
    #
    # Gem.user_dir:
    # # ~/.local/share/gem/ruby/<VERSION>
    # Gem.dir:
    # # ~/.gem
    #
    # @seealso
    # - https://guides.rubygems.org/faqs/
    # """
    local -A app dict
    app['ruby']="$(koopa_locate_ruby)"
    koopa_assert_is_executable "${app[@]}"
    dict['str']="$("${app['ruby']}" -r rubygems -e 'puts Gem.user_dir')"
    [[ -n "${dict['str']}" ]] || return 1
    koopa_print "${dict['str']}"
    return 0
}

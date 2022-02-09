#!/usr/bin/env bash

# FIXME Now seeing this error with Ruby 3.1:
# Building native extensions. This could take a while...
# ERROR:  While executing gem ... (Errno::EACCES)
#     Permission denied @ rb_sysopen - /usr/local/Cellar/ruby/3.1.0/lib/ruby/gems/3.1.0/specifications/debug-1.4.0.gemspec

koopa:::install_ruby_packages() { # {{{1
    # """
    # Install Ruby packages (gems).
    # @note Updated 2022-01-26.
    #
    # @seealso
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # """
    local app dict gem gems
    koopa::assert_has_no_args "$#"
    koopa::configure_ruby
    koopa::activate_ruby
    declare -A app=(
        [gem]="$(koopa::locate_gem)"
    )
    declare -A dict=(
        [gemdir]="$("${app[gem]}" environment 'gemdir')"
    )
    gems=(
        # > 'neovim'
        'bundler'
        'bashcov'
        'ronn'
    )
    koopa::dl \
        'Target' "${dict[gemdir]}" \
        'Gems' "$(koopa::to_string "${gems[@]}")"
    if koopa::is_macos
    then
        koopa::activate_homebrew_opt_prefix 'libffi'
    fi
    "${app[gem]}" cleanup
    "${app[gem]}" pristine --all
    # > if koopa::is_shared_install
    # > then
    # >     "${app[gem]}" update --system
    # > fi
    for gem in "${gems[@]}"
    do
        "${app[gem]}" install "$gem"
    done
    "${app[gem]}" cleanup
    return 0
}

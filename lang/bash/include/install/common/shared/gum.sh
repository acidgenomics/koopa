#!/usr/bin/env bash

main() {
    # """
    # Install gum.
    # @note Updated 2023-08-28.
    #
    # @seealso
    # - https://github.com/charmbracelet/gum
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/gum.rb
    # """
    local -A app dict
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['url']="https://github.com/charmbracelet/gum/archive/\
v${dict['version']}.tar.gz"
    dict['ldflags']="-s -w -X main.Version=${dict['version']}"
    koopa_install_app_subshell \
        --installer='go-package' \
        --name='gum' \
        -D "--ldflags=${dict['ldflags']}" \
        -D "--url=${dict['url']}"
    app['gum']="${dict['prefix']}/bin/gum"
    koopa_assert_is_executable "${app['gum']}"
    dict['bash_c']="${dict['prefix']}/etc/bash_completion.d/gum"
    dict['fish_c']="${dict['prefix']}/share/fish/vendor_completions.d/gum.fish"
    dict['zsh_c']="${dict['prefix']}/share/zsh/site-functions/_gum"
    dict['manfile']="${dict['prefix']}/share/man/man1/gum.1"
    koopa_touch \
        "${dict['bash_c']}" \
        "${dict['fish_c']}" \
        "${dict['zsh_c']}" \
        "${dict['manfile']}"
    "${app['gum']}" completion bash > "${dict['bash_c']}"
    "${app['gum']}" completion fish > "${dict['fish_c']}"
    "${app['gum']}" completion zsh > "${dict['zsh_c']}"
    "${app['gum']}" man > "${dict['manfile']}"
    return 0
}

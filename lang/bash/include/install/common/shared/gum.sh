#!/usr/bin/env bash

main() {
    # """
    # Install gum.
    # @note Updated 2023-07-29.
    #
    # @seealso
    # - https://github.com/charmbracelet/gum
    # - https://github.com/Homebrew/homebrew-core/blob/HEAD/Formula/gum.rb
    # """
    local -A app dict
    koopa_activate_app --build-only 'go'
    app['go']="$(koopa_locate_go)"
    koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(koopa_init_dir 'gocache')"
    dict['gopath']="$(koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    dict['url']="https://github.com/charmbracelet/gum/\
archive/v${dict['version']}.tar.gz"
    koopa_download "${dict['url']}"
    koopa_extract "$(koopa_basename "${dict['url']}")" 'src'
    koopa_cd 'src'
    app['gum']="${dict['prefix']}/bin/gum"
    dict['ldflags']="-s -w -X main.Version=${dict['version']}"
    "${app['go']}" build \
        -ldflags "${dict['ldflags']}" \
        -o "${app['gum']}"
    dict['bash_c']="${dict['prefix']}/etc/bash_completion.d/gum"
    dict['fish_c']="${dict['prefix']}/share/fish/vendor_completions.d/gum.fish"
    dict['zsh_c']="${dict['prefix']}/share/zsh/site-functions/_gum"
    dict['manfile']="${dict['prefix']}/share/man/man1/gum.1"
    koopa_touch \
        "${dict['bash_c']}" \
        "${dict['fish_c']}" \
        "${dict['zsh_c']}" \
        "${dict['manfile']}"
    koopa_assert_is_executable "${app['gum']}"
    "${app['gum']}" completion bash > "${dict['bash_c']}"
    "${app['gum']}" completion fish > "${dict['fish_c']}"
    "${app['gum']}" completion zsh > "${dict['zsh_c']}"
    "${app['gum']}" man > "${dict['manfile']}"
    koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

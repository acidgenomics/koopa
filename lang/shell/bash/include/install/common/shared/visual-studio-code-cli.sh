#!/usr/bin/env bash

main() {
    # """
    # Install Visual Studio Code CLI.
    # @note Updated 2023-03-22.
    #
    # @seealso
    # - https://code.visualstudio.com/#alt-downloads
    # - https://github.com/Homebrew/homebrew-core/blob/master/
    #     Formula/code-cli.rb
    # """
    local dict
    declare -A dict

    # https://github.com/microsoft/vscode/archive/refs/tags/1.76.2.tar.gz
    dict['file']='setup.sh'
    dict['url']="https://aka.ms/install-vscode-server/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    #ENV["VSCODE_CLI_NAME_LONG"] = "Code OSS"
    #ENV["VSCODE_CLI_VERSION"] = version
    #cd "cli" do
    #  system "cargo", "install", *std_cargo_args
    #end

    return 0
}

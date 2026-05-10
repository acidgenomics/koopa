# Nushell header.
# @note Updated 2026-05-01.
# @note Requires nushell 0.90+.
#
# Usage:
#     1. Set KOOPA_PREFIX in your env.nu:
#         $env.KOOPA_PREFIX = '/path/to/koopa'
#
#     2. Source this header in your config.nu:
#         use /path/to/koopa/lang/nushell/include/header.nu *
#
#     3. For tool integrations that require parse-time sourcing
#        (starship, zoxide), run koopa activation once to generate
#        cached .nu files, then source them in config.nu:
#         source ~/.cache/koopa/starship.nu
#         source ~/.cache/koopa/zoxide.nu
#
# Note: Nushell's parse-time source requirement means that dynamic
# tool init (eval) is not supported the way it is in bash/zsh/fish.
# Instead, this module generates cached .nu files for tools that
# produce shell code, and those files must be sourced separately.

# Source function modules.
# Note: In nushell, 'use' and 'source' require known paths at parse time.
# We use 'export use' to re-export all functions from submodules.
export use ../functions/core/add-to-path-start.nu *
export use ../functions/core/add-to-path-end.nu *
export use ../functions/core/is-installed.nu *
export use ../functions/core/is-macos.nu *
export use ../functions/prefix/koopa-prefix.nu *
export use ../functions/prefix/bin-prefix.nu *
export use ../functions/prefix/opt-prefix.nu *
export use ../functions/prefix/xdg-data-home.nu *
export use ../functions/prefix/xdg-config-home.nu *
export use ../functions/export/export-env.nu *
export use ../functions/activate/activate-bootstrap.nu *
export use ../functions/activate/activate-fzf.nu *
export use ../functions/activate/activate-direnv.nu *
export use ../functions/activate/activate-zoxide.nu *
export use ../functions/activate/activate-starship.nu *
export use ../functions/activate/activate-aliases.nu *

# Main activation function.
# @note Updated 2026-05-01.
export def _koopa_activate_koopa [] {
    let koopa_minimal = ($env | get -i KOOPA_MINIMAL | default "0")

    _koopa_activate_bootstrap
    _koopa_add_to_path_start $"($env.KOOPA_PREFIX)/bin"

    if $koopa_minimal == "1" {
        return
    }

    _koopa_export_env
    _koopa_activate_fzf
    _koopa_activate_direnv
    _koopa_activate_zoxide
    _koopa_activate_starship

    # macOS-specific: Homebrew.
    if (_koopa_is_macos) {
        if ("/opt/homebrew/bin/brew" | path exists) {
            let brew_env = (^/opt/homebrew/bin/brew shellenv | lines | each { |line|
                let parts = ($line | parse -r 'export (?P<key>[^=]+)="(?P<val>[^"]*)"')
                if ($parts | is-not-empty) {
                    { key: ($parts | get 0.key), val: ($parts | get 0.val) }
                }
            } | compact)
            for entry in $brew_env {
                load-env { ($entry.key): ($entry.val) }
            }
        }
    }

    # Final PATH additions.
    _koopa_add_to_path_start ...[
        "/usr/local/sbin"
        "/usr/local/bin"
        $"((_koopa_xdg_config_home))/koopa/scripts-private/bin"
        $"($env.HOME)/.local/bin"
        $"($env.HOME)/.bin"
        $"($env.HOME)/bin"
    ]
}

# Run activation if KOOPA_ACTIVATE is set.
export def _koopa_run_activation [] {
    let koopa_activate = ($env | get -i KOOPA_ACTIVATE | default "0")
    if $koopa_activate == "1" {
        _koopa_activate_koopa
    }
}

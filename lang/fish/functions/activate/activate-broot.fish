function _koopa_activate_broot
    # Activate broot directory tree utility.
    # @note Updated 2026-05-01.
    test -x "(_koopa_bin_prefix)/broot"; or return 0
    set -l config_dir (_koopa_xdg_config_home)/broot
    if not test -d "$config_dir"
        return 0
    end
    set -l script "$config_dir/launcher/fish/br"
    if not test -f "$script"
        return 0
    end
    functions -q br; and functions -e br
    source "$script"
end

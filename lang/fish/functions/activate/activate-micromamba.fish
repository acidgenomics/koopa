function _koopa_activate_micromamba
    # Activate micromamba environment variables.
    # @note Updated 2026-06-13.
    if not set -q MAMBA_ROOT_PREFIX
        set -gx MAMBA_ROOT_PREFIX "$HOME/.mamba"
    end
end

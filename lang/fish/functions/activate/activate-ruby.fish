function _koopa_activate_ruby
    # Activate Ruby gem environment.
    # @note Updated 2026-06-13.
    set -l prefix "$HOME/.gem"
    set -gx GEM_HOME "$prefix"
    _koopa_add_to_path_start "$prefix/bin"
end

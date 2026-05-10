function _koopa_activate_bootstrap
    # Conditionally activate koopa bootstrap in current path.
    # @note Updated 2026-05-01.
    set -l bootstrap_prefix (_koopa_bootstrap_prefix)
    if not test -d "$bootstrap_prefix"
        return 0
    end
    set -l opt_prefix (_koopa_opt_prefix)
    if test -d "$opt_prefix/bash" \
        -a -d "$opt_prefix/coreutils" \
        -a -d "$opt_prefix/openssl3" \
        -a -d "$opt_prefix/python3.12" \
        -a -d "$opt_prefix/zlib"
        return 0
    end
    _koopa_add_to_path_start "$bootstrap_prefix/bin"
end

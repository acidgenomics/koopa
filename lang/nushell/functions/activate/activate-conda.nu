# Activate conda.
# @note Updated 2026-05-12.
#
# Nushell doesn't have a native conda shell hook, so we use a PATH-only
# approach to make conda commands available in the base environment.
export def _koopa_activate_conda [] {
    let prefix = $"((_koopa_opt_prefix))/conda"
    if not ($prefix | path exists) {
        return
    }
    let conda = $"($prefix)/bin/conda"
    if not ($conda | path exists) {
        return
    }
    _koopa_add_to_path_start $"($prefix)/bin"
}

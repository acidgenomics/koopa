# Activate conda.
# @note Updated 2026-05-12.
#
# Elvish doesn't have a native conda shell hook, so we use a PATH-only
# approach to make conda commands available in the base environment.
use path

fn activate-conda {
    var prefix = (opt-prefix)'/conda'
    if (not (path:is-dir $prefix)) {
        return
    }
    var conda = $prefix'/bin/conda'
    if (not (path:is-regular &follow-symlink $conda)) {
        return
    }
    add-to-path-start $prefix'/bin'
}

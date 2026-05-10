# Conditionally activate koopa bootstrap in current path.
# @note Updated 2026-05-01.
fn activate-bootstrap {
    var bootstrap-prefix = (xdg-data-home)'/koopa-bootstrap'
    if (not (path:is-dir $bootstrap-prefix)) {
        return
    }
    var opt-prefix = (opt-prefix)
    var has-all = (and ^
        (path:is-dir $opt-prefix'/bash') ^
        (path:is-dir $opt-prefix'/coreutils') ^
        (path:is-dir $opt-prefix'/openssl3') ^
        (path:is-dir $opt-prefix'/python3.12') ^
        (path:is-dir $opt-prefix'/zlib'))
    if $has-all {
        return
    }
    add-to-path-start $bootstrap-prefix'/bin'
}

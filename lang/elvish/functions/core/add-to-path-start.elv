# Force add directories to PATH start.
# @note Updated 2026-05-01.
fn add-to-path-start {|@dirs|
    for dir $dirs {
        if (path:is-dir $dir) {
            set paths = [$dir (all $paths | each {|p|
                if (not-eq $p $dir) { put $p }
            })]
        }
    }
}

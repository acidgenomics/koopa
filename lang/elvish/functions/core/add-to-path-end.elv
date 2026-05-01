# Force add directories to PATH end.
# @note Updated 2026-05-01.
fn add-to-path-end {|@dirs|
    for dir $dirs {
        if (path:is-dir $dir) {
            set paths = [(all $paths | each {|p|
                if (not-eq $p $dir) { put $p }
            }) $dir]
        }
    }
}

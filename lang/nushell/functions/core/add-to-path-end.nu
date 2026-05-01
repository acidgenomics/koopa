# Force add directories to PATH end.
# @note Updated 2026-05-01.
export def _koopa_add_to_path_end [...dirs: string] {
    mut path = $env.PATH
    for dir in $dirs {
        if ($dir | path exists) and ($dir | path type) == "dir" {
            $path = ($path | where $it != $dir | append $dir)
        }
    }
    $env.PATH = $path
}

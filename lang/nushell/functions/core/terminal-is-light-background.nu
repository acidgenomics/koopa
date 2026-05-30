# Query terminal background color via OSC 11.
# @note Updated 2026-05-30.
export def _koopa_terminal_is_light_background [] {
    try {
        let response = (
            do {
                print -n "\x1b]11;?\x1b\\"
                $in
            } | head -c 64
        )
        let rgb = ($response | parse -r 'rgb:(?P<rgb>[0-9a-fA-F/]+)' | get rgb | first)
        let parts = ($rgb | split row '/')
        if ($parts | length) < 3 { return false }
        let r = ($parts.0 | str substring 0..1 | into int --radix 16)
        let g = ($parts.1 | str substring 0..1 | into int --radix 16)
        let b = ($parts.2 | str substring 0..1 | into int --radix 16)
        let luma = (($r * 299 + $g * 587 + $b * 114) / 1000)
        $luma > 128
    } catch {
        false
    }
}

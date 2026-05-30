# Query terminal background color via OSC 11.
# @note Updated 2026-05-30.
fn terminal-is-light-background {
    try {
        var old-settings = (stty -g)
        stty raw -echo min 0 time 2
        print "\x1b]11;?\x1b\\" > /dev/tty
        var response = (dd bs=64 count=1 < /dev/tty 2>/dev/null)
        stty $old-settings
        var rgb-part = (str:trim-suffix
            (str:trim-suffix
                (str:after-last $response 'rgb:')
                "\x1b\\")
            "\x07")
        var parts = [(str:split '/' $rgb-part)]
        if (< (count $parts) 3) {
            return $false
        }
        var r = (printf '%d' '0x'(str:to-upper (str:substring 0 2 $parts[0])))
        var g = (printf '%d' '0x'(str:to-upper (str:substring 0 2 $parts[1])))
        var b = (printf '%d' '0x'(str:to-upper (str:substring 0 2 $parts[2])))
        var luma = (math:trunc (/ (+ (* $r 299) (* $g 587) (* $b 114)) 1000))
        put (> $luma 128)
    } catch {
        put $false
    }
}

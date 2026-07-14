# Query terminal background color via OSC 11.
# @note Updated 2026-05-30.
function _koopa_terminal_is_light_background {
    if (-not [Console]::IsInputRedirected) { return $false }
    if ($env:TMUX -or $env:TERM -like 'screen*' -or $env:TERM -like 'tmux*') { return $false }
    # Hoist $oldMode before try so the finally block can always restore it,
    # even if an exception is thrown after TreatControlCAsInput is set.
    $oldMode = [Console]::TreatControlCAsInput
    try {
        [Console]::TreatControlCAsInput = $true
        [Console]::Write("`e]11;?`e\")
        Start-Sleep -Milliseconds 200
        $response = ''
        while ([Console]::KeyAvailable) {
            $key = [Console]::ReadKey($true)
            $response += $key.KeyChar
        }
        if ($response -match 'rgb:([0-9a-fA-F]+)/([0-9a-fA-F]+)/([0-9a-fA-F]+)') {
            $r = [Convert]::ToInt32($Matches[1].Substring(0,2), 16)
            $g = [Convert]::ToInt32($Matches[2].Substring(0,2), 16)
            $b = [Convert]::ToInt32($Matches[3].Substring(0,2), 16)
            $luma = ($r * 299 + $g * 587 + $b * 114) / 1000
            return $luma -gt 128
        }
    } catch {
    } finally {
        # Always restore the original mode, even if an exception was thrown.
        [Console]::TreatControlCAsInput = $oldMode
    }
    return $false
}

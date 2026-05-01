# Koopa shell bootloader activation for nushell.
# @note Updated 2026-05-01.
# @note Requires nushell 0.90+.
#
# Usage:
#     Set KOOPA_PREFIX in your env.nu, then source this file in config.nu:
#
#     # In env.nu:
#     $env.KOOPA_PREFIX = '/path/to/koopa'
#
#     # In config.nu:
#     source /path/to/koopa/activate.nu
#
# Alternatively, source the header directly:
#     source /path/to/koopa/lang/nushell/include/header.nu

if not ($env | get -i KOOPA_PREFIX | is-empty) {
    # Already set by user in env.nu.
} else {
    # Attempt to derive from this file's location.
    # Note: nushell does not reliably provide the sourced file's path
    # at runtime. KOOPA_PREFIX should be set in env.nu.
    print -e "koopa: KOOPA_PREFIX must be set before sourcing activate.nu."
    return
}

$env.KOOPA_ACTIVATE = 1

# Source the nushell header.
# Note: nushell requires source paths to be known at parse time.
# Users must update this path to match their installation.
use ($env.KOOPA_PREFIX + "/lang/nushell/include/header.nu") *

$env.KOOPA_ACTIVATE = null

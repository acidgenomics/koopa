# Activate aliases for nushell.
# @note Updated 2026-05-01.
#
# Note: In nushell, 'alias' must be defined at parse time (module level).
# This file defines aliases as exports that can be used with 'use'.
# Runtime alias definition is not supported in nushell.

# Navigation.
export alias '..' = cd ..
export alias '...' = cd ../..
export alias '....' = cd ../../..
export alias '.....' = cd ../../../..

# Shortcuts.
export alias c = clear
export alias e = exit
export alias g = git
export alias q = exit

# Koopa.
export alias k = koopa

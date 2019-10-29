#!/bin/sh

# Homebrew.
# Updated 2019-10-29.

_koopa_is_installed brew || return 0



# Core                                                                      {{{1
# ==============================================================================

HOMEBREW_PREFIX="$(brew --prefix)"
export HOMEBREW_PREFIX
HOMEBREW_REPOSITORY="$(brew --repo)"
export HOMEBREW_REPOSITORY
export HOMEBREW_INSTALL_CLEANUP=1
export HOMEBREW_NO_ANALYTICS=1



# GNU coreutils                                                             {{{1
# ==============================================================================

# Linked using "g*" prefix by default.
# > brew info coreutils

prefix="/usr/local/opt/coreutils/libexec"
if [ -d "$prefix" ]
then
    _koopa_force_add_to_path_start "${prefix}/gnubin"
    _koopa_force_add_to_manpath_start "${prefix}/gnuman"
fi
unset -v prefix



# Python                                                                    {{{1
# ==============================================================================

# Don't add to PATH if a virtual environment is active.
#
# See also:
# - https://docs.brew.sh/Homebrew-and-Python
# - brew info python

if [ -z "${VIRTUAL_ENV:-}" ]
then
    _koopa_add_to_path_start "/usr/local/opt/python/libexec/bin"
fi



# Google Cloud SDK                                                          {{{1
# ==============================================================================

prefix="${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
if [ -d "$prefix" ]
then
    # shellcheck source=/dev/null
    . "${prefix}/path.bash.inc"
    # shellcheck source=/dev/null
    . "${prefix}/completion.bash.inc"
fi
unset -v prefix

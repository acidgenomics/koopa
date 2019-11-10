#!/bin/sh
# shellcheck disable=SC2039

_acid_is_installed brew || return 0



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
    _acid_force_add_to_path_start "${prefix}/gnubin"
    _acid_force_add_to_manpath_start "${prefix}/gnuman"
fi
unset -v prefix



# Python                                                                    {{{1
# ==============================================================================

# Homebrew is lagging on new Python releases, so install manually instead.
# See 'python.sh' script for activation.
#
# Don't add to PATH if a virtual environment is active.
#
# See also:
# - https://docs.brew.sh/Homebrew-and-Python
# - brew info python

# > if [ -z "${VIRTUAL_ENV:-}" ]
# > then
# >     # /usr/local/opt/python/bin
# >     _acid_add_to_path_start "/usr/local/opt/python/libexec/bin"
# >     _acid_add_to_manpath_start "/usr/local/opt/python/share/man"
# > fi



# Google Cloud SDK                                                          {{{1
# ==============================================================================

_acid_activate_google_cloud_sdk() {
    # > ! _acid_is_installed gcloud || return 0
    local prefix
    prefix="${HOMEBREW_PREFIX}"
    prefix="${prefix}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
    [ -d "$prefix" ] || return 0
    local shell
    shell="$(_acid_shell)"
    # shellcheck source=/dev/null
    . "${prefix}/path.${shell}.inc"
    # shellcheck source=/dev/null
    . "${prefix}/completion.${shell}.inc"
}

_acid_activate_google_cloud_sdk


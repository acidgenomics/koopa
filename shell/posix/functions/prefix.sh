#!/bin/sh
# shellcheck disable=SC2039



# Koopa system                                                              {{{1
# ==============================================================================

_koopa_prefix() {                                                         # {{{3
    # """
    # Koopa prefix (home).
    # Updated 2019-08-18.
    # """
    echo "$KOOPA_PREFIX"
}

_koopa_app_prefix() {                                                     # {{{3
    # """
    # Custom application install prefix.
    # Updated 2019-11-14.
    #
    # Inspired by HMS RC devops approach on O2 cluster.
    # """
    local prefix
    if _koopa_is_shared_install
    then
        prefix="/n/app"
    else
        prefix="$XDG_DATA_HOME"
    fi
    echo "$prefix"
}

_koopa_cellar_prefix() {                                                  # {{{3
    # """
    # Cellar prefix.
    # Updated 2019-11-14.
    #
    # Ensure this points to a local mount (e.g. '/usr/local') instead of our
    # app dir (e.g. '/n/app'), otherwise you can run into login shell activation
    # issues on some virtual machines.
    # """
    echo "$(_koopa_make_prefix)/cellar"
}

_koopa_config_prefix() {                                                  # {{{3
    # """
    # Local koopa config directory.
    # Updated 2019-11-06.
    # """
    if [ -z "${XDG_CONFIG_HOME:-}" ]
    then
        # > _koopa_warning "'XDG_CONFIG_HOME' is unset."
        XDG_CONFIG_HOME="${HOME}/.config"
    fi
    echo "${XDG_CONFIG_HOME}/koopa"
}

_koopa_make_prefix() {                                                    # {{{3
    # """
    # Return the installation prefix to use.
    # Updated 2019-09-27.
    # """
    local prefix
    if _koopa_is_shared_install && _koopa_has_sudo
    then
        prefix="/usr/local"
    else
        prefix="${HOME}/.local"
    fi
    echo "$prefix"
}



# Applications                                                              {{{1
# ==============================================================================

_koopa_aspera_prefix() {                                                  # {{{3
    # """
    # Aspera Connect prefix.
    # Updated 2019-11-15.
    # """
    echo "${HOME}/.aspera/connect"
}

_koopa_autojump_prefix() {                                                # {{{3
    # """
    # autojump prefix.
    # Updated 2019-11-15.
    # """
    echo "${HOME}/.autojump"
}

_koopa_bcbio_prefix() {                                                   # {{{3
    # """
    # bcbio-nextgen prefix.
    # Updated 2019-11-25.
    local prefix
    local host_id
    host_id="$(_koopa_host_id)"
    if [ "$host_id" = "harvard-o2" ]
    then
        prefix="/n/app/bcbio/tools"
    elif [ "$host_id" = "harvard-odyssey" ]
    then
        prefix="/n/regal/hsph_bioinfo/bcbio_nextgen"
    else
        prefix="$(_koopa_app_prefix)/bcbio/stable/tools"
    fi
    echo "$prefix"
}

_koopa_conda_prefix() {
    # """
    # Conda prefix
    # Updated 2019-11-21.
    # """
    _koopa_assert_is_installed conda
    conda info --base
}

_koopa_ensembl_perl_api_prefix() {                                        # {{{3
    # """
    # Ensembl Perl API prefix.
    # Updated 2019-11-15.
    local prefix
    prefix="$(_koopa_app_prefix)/ensembl"
    echo "$prefix"
}

_koopa_java_home() {                                                      # {{{3
    # """
    # Java home.
    # Updated 2019-11-16.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    # """
    if ! _koopa_is_installed java
    then
        return 0
    fi
    # Early return if environment variable is set.
    if [ -n "${JAVA_HOME:-}" ]
    then
        echo "$JAVA_HOME"
        return 0
    fi
    local home
    if _koopa_is_darwin
    then
        home="$(/usr/libexec/java_home)"
    else
        local java_exe
        java_exe="$(_koopa_which_realpath "java")"
        home="$(dirname "$(dirname "${java_exe}")")"
    fi
    echo "$home"
}

_koopa_perlbrew_prefix() {                                                # {{{3
    # """
    # Perlbrew prefix.
    # Updated 2019-11-15.
    # """
    local prefix
    prefix="$(_koopa_app_prefix)/perlbrew"
    echo "$prefix"
}

_koopa_pyenv_prefix() {                                                   # {{{3
    # """
    # pyenv prefix.
    # Updated 2019-11-15.
    # """
    echo "${XDG_DATA_HOME}/pyenv"
}

_koopa_r_home() {                                                         # {{{3
    # """
    # Get 'R_HOME', rather than exporting as global variable.
    # Updated 2019-06-27.
    # """
    _koopa_assert_is_installed R
    _koopa_assert_is_installed Rscript
    Rscript --vanilla -e 'cat(Sys.getenv("R_HOME"))'
}

_koopa_rbenv_prefix() {                                                   # {{{3
    # """
    # rbenv prefix.
    # Updated 2019-11-15.
    # """
    echo "${XDG_DATA_HOME}/rbenv"
}

_koopa_rust_prefix() {                                                    # {{{3
    # """
    # Rust prefix.
    # Updated 2019-11-15.
    # """
    echo "${HOME}/.cargo"
}

_koopa_venv_prefix() {                                                    # {{{3
    # """
    # Python venv prefix.
    # Updated 2019-11-15.
    # """
    echo "${XDG_DATA_HOME}/virtualenvs"
}

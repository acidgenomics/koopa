#!/usr/bin/env bash

# FIXME Consider renaming this to 'koopa_configure_r_environ'.
# FIXME Rework this to save lines and then export at the final step.

koopa_r_environ() {
    # """
    # Generate 'Renviron.site' file.
    # @note Updated 2022-07-23.
    #
    # @section Package library location:
    #
    # General:
    # - 'Sys.getenv()'.
    # - 'help(topic = "R_LIBS_USER")'.
    # - 'help(topic = ".libPaths")'.
    #
    # Bioconductor-specific:
    # - https://www.bioconductor.org/developers/how-to/useDevel/
    #
    # Variables:
    # - '%V': R version number including the patchlevel (e.g., '2.5.0').
    # - '%v': R version number excluding the patchlevel (e.g., '2.5').
    # - '%p': The platform for which R was built;
    #   value of 'R.version$platform'.
    # - '%o': The underlying operating system;
    #   value of 'R.version$os'.
    # - '%a': The CPU architecture (CPU);
    #   value of 'R.version$arch'.
    #
    # Linux default:
    # > R_LIBS_USER="~/R/%p-library/%v"
    #
    # macOS default (3.6+):
    # > R_LIBS_USER="~/Library/R/%v/library"
    #
    # Windows default:
    # > R_LIBS_USER="~/R/win-library/%v"
    #
    # '@R_PLATFORM@' can be e.g. 'x86_64-pc-linux-gnu'.
    # '@MAJ_MIN_VERSION@' is likely something like '3.6'.
    #
    # Set this per-user via '%p' and '%v' for platform and version.
    # > R_LIBS_USER="~/R/@R_PLATFORM@-library/@MAJ_MIN_VERSION@"
    #
    # Note that RStudio Server can disable user package installations.
    # Set 'allow-package-installation=0' in '/etc/rstudio/rsession.conf'.
    #
    # Check the return of these in an R session:
    # - '.libPaths()'
    # - '.Library'
    # - '.Library.site'
    #
    # @section Default packages:
    #
    # Example of setting 'R_DEFAULT_PACKAGES' (from 'R CMD check'). This loads
    # the packages in the order given, so they appear on the search path in
    # reverse order.
    # > R_DEFAULT_PACKAGES='utils,grDevices,graphics,stats'
    #
    # @seealso
    # - 'help(Startup)' for documentation on '~/.Renviron' and 'Renviron.site'.
    # - https://support.rstudio.com/hc/en-us/articles/215733837
    # - https://cran.r-project.org/doc/manuals/r-release/
    #       R-admin.html#Managing-libraries
    # - https://community.rstudio.com/t/setting-up-a-site-library/3916
    # - Debian example config file by Dirk Eddelbuettel.
    # - http://mac.r-project.org/
    # - https://cran.r-project.org/bin/macosx/tools/
    # """
    local app dict i pkgconfig pkg pkgs
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
        [r]="${1:?}"
    )
    [[ -x "${app[cat]}" ]] || return 1
    [[ -x "${app[r]}" ]] || return 1
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [opt_prefix]="$(koopa_opt_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
        [system]=0
        [tmp_file]="$(koopa_tmp_file)"
    )
    dict[file]="${dict[r_prefix]}/etc/Renviron.site"
    ! koopa_is_koopa_app "${app[r]}" && dict[system]=1
    koopa_alert "Configuring '${dict[file]}'."
    "${app[cat]}" <<END >>"${dict[tmp_file]}"
R_LIBS_SITE="\${R_HOME}/site-library"
R_LIBS_USER="\${R_LIBS_SITE}"
# Restrict path, so we don't mask compiler binaries with virtual environment.
# This also greatly improves consistency when running inside RStudio.
PATH="/usr/bin:/bin"
PATH="\${dict[koopa_prefix]}/bin:\${PATH}"
END
    if koopa_is_macos
    then
        "${app[cat]}" >> "${dict[tmp_file]}" << END
PATH="/Applications/RStudio.app/Contents/MacOS/pandoc:\${PATH}"
PATH="\${PATH}:/Library/TeX/texbin"
END
    fi
    "${app[cat]}" >> "${dict[tmp_file]}" << END
PKG_CONFIG_PATH=""
END
    pkgs=(
        'fontconfig'
        'freetype'
        'fribidi'
        'gdal'
        'geos'
        'graphviz'
        'harfbuzz'
        'icu4c'
        'imagemagick'
        'lapack'
        'libgit2'
        'libjpeg-turbo'
        'libpng'
        'libssh2'
        'libtiff'
        'openblas'
        'openssl3'
        'pcre2'
        'proj'
        'readline'
        'xz'
        'zlib'
        'zstd'
    )
    declare -A pkgconfig
    for pkg in "${pkgs[@]}"
    do
        pkgconfig[$pkg]="$(koopa_realpath "${dict[opt_prefix]}/${pkg}")"
    done
    for i in "${!pkgconfig[@]}"
    do
        pkgconfig[$i]="${pkgconfig[$i]}/lib"
    done
    if koopa_is_linux
    then
        pkgconfig[harfbuzz]="${pkgconfig[harfbuzz]}64"
    fi
    for i in "${!pkgconfig[@]}"
    do
        pkgconfig[$i]="${pkgconfig[$i]}/pkgconfig"
        "${app[cat]}" >> "${dict[tmp_file]}" << END
PKG_CONFIG_PATH="${pkgconfig[$i]}:\${PKG_CONFIG_PATH}"
END
    done
    "${app[cat]}" >> "${dict[tmp_file]}" << END
PAGER="\${PAGER:-less}"
TZ="\${TZ:-America/New_York}"
R_PAPERSIZE="letter"
R_PAPERSIZE_USER="\${R_PAPERSIZE}"
END
    if koopa_is_linux
    then
    "${app[cat]}" >> "${dict[tmp_file]}" << END
R_BROWSER="\${R_BROWSER:-xdg-open}"
R_PRINTCMD="\${R_PRINTCMD:-lpr}"
END
    elif koopa_is_macos
    then
    "${app[cat]}" >> "${dict[tmp_file]}" << END
R_MAX_NUM_DLLS=153
END
    fi
    dict[conda]="$(koopa_realpath "${dict[opt_prefix]}/conda")"
    dict[udunits2]="$(koopa_realpath "${dict[opt_prefix]}/udunits")"
    "${app[cat]}" >> "${dict[tmp_file]}" << END
# data.table
# ------------------------------------------------------------------------------
#
# Refer to 'data.table::getDTthreads' for more info.
R_DATATABLE_NUM_PROCS_PERCENT=100
#
# rcmdcheck
# ------------------------------------------------------------------------------
#
# Options: "never", "error", "warning", "note".
RCMDCHECK_ERROR_ON="warning"
#
# remotes
# ------------------------------------------------------------------------------
#
# Always upgrade GitHub R packages, without prompting.
# See 'remotes::update_packages()' for details.
R_REMOTES_UPGRADE="always"
#
# Standalone mode. remotes will use the curl, git2r and pkgbuild packages if
# they are installed to provide faster implementations for some aspects of the
# install process. However if you are using remotes to install or update these
# packages (or their reverse dependencies) using them during installation may
# fail (particularly on Windows).
R_REMOTES_STANDALONE="true"
#
# reticulate
# ------------------------------------------------------------------------------
#
# Ensure the default location of Miniconda is standardized.
RETICULATE_MINICONDA_PATH="${dict[conda]}"
#
# Default path to virtual environments.
# Check with 'virtualenv_list()'.
# https://rstudio.github.io/reticulate/reference/virtualenv-tools.html
WORKON_HOME="\${HOME}/.virtualenvs"
#
# stringi
# ------------------------------------------------------------------------------
#
# Ensure usage of system ICU, insteading of building bundle from source.
STRINGI_DISABLE_ICU_BUNDLE=1
#
# Alternatively, ensure that ICU bundle is compiled from source.
# > STRINGI_DISABLE_PKG_CONFIG=1
#
# tools
# ------------------------------------------------------------------------------
#
# These values are inherited by 'tools::R_user_dir()'.
R_USER_CACHE_DIR="\${XDG_CACHE_HOME:-~/.cache}"
R_USER_CONFIG_DIR="\${XDG_CONFIG_HOME:-~/.config}"
R_USER_DATA_DIR="\${XDG_DATA_HOME:-~/.local/share}"
#
# units
# ------------------------------------------------------------------------------
#
# The units package requires udunits2 to be installed.
UDUNITS2_INCLUDE="${dict[udunits2]}/include"
UDUNITS2_LIBS="${dict[udunits2]}/lib"
END
    if koopa_is_fedora_like
    then
        dict[oracle_ver]="$(koopa_variable 'oracle-instant-client')"
        dict[oracle_ver]="$(koopa_major_minor_version "${dict[oracle_ver]}")"
        "${app[cat]}" >> "${dict[tmp_file]}" << END
# ROracle
# ------------------------------------------------------------------------------
#
# This requires installation of the Oracle Database Instant Client.
# Install with 'koopa install system oracle-instant-client'.
#
OCI_VERSION="${dict[oracle_ver]}"
ORACLE_HOME="\${ORACLE_HOME-/usr/lib/oracle/\${OCI_VERSION}/client64}"
OCI_INC="\${OCI_INC-/usr/include/oracle/\${OCI_VERSION}/client64}"
OCI_LIB="\${ORACLE_HOME}/lib"
TNS_ADMIN="\${ORACLE_HOME}/network/admin"
PATH="\${PATH}:\${ORACLE_HOME}/bin"
END
    fi
    "${app[cat]}" >> "${dict[tmp_file]}" << END
# Avoid issue with file timestamp check:
#     > N  checking for future file timestamps
#     >    unable to verify current time
# https://stackoverflow.com/questions/63613301/
_R_CHECK_SYSTEM_CLOCK_=0
#
# Debian (and its derivatives) impose a set of compiler flags to prevent some
# known security issues with compiled code. These flags then become defaults
# for R as well (see eg '/etc/R/Makeconf'), but nevertheless confuse R as
# warnings get triggered.  Users, on the other hand, are often stumped about
# these. So with this variable we declare these options as known for the local
# checks on the machine this file is on. See Section 8 of the R Internals manual
# for many more options.
_R_CHECK_COMPILATION_FLAGS_KNOWN_="-Wformat -Werror=format-security -Wdate-time"
#
# Logical coercion. Verbose information on 'length(x) = n > 1' coercion to
# 'logical(1)' errors. Set to 'false' to disable. Note that setting these can
# cause Shiny Server to crash.
#
# See also:
# - https://twitter.com/henrikbengtsson/status/1172155983935631360
# - https://twitter.com/henrikbengtsson/status/1188197161780989953
# - https://github.com/rstudio/rstudio/issues/5268
_R_CHECK_LENGTH_1_CONDITION_="\${_R_CHECK_LENGTH_1_CONDITION_-verbose}"
_R_CHECK_LENGTH_1_LOGIC2_="\${_R_CHECK_LENGTH_1_LOGIC2_-verbose}"
#
# Don't truncate R CMD check output.
#
# See also:
# - https://twitter.com/michael_chirico/status/1193831562724331520
# - https://yihui.name/en/2017/12/last-13-lines-of-output/
_R_CHECK_TESTS_NLINES_=0
#
# Additional Bioconductor recommendations.
#
# See also:
# - https://raw.githubusercontent.com/Bioconductor/BBS/master/
#       3.11/R_env_vars.sh
# - https://github.com/Bioconductor/bioconductor_docker
#
# > _R_CHECK_LENGTH_1_CONDITION_="package:_R_CHECK_PACKAGE_NAME_,abort,verbose"
# > _R_CHECK_LENGTH_1_LOGIC2_="package:_R_CHECK_PACKAGE_NAME_,abort,verbose"
# > _R_CHECK_TIMINGS_=0
# > _R_CLASS_MATRIX_ARRAY_="true"
# > _R_S3_METHOD_LOOKUP_BASEENV_AFTER_GLOBALENV_="true"
_R_CHECK_EXECUTABLES_="false"
_R_CHECK_EXECUTABLES_EXCLUSIONS_="false"
_R_CHECK_S3_METHODS_NOT_REGISTERED_="true"
END
    case "${dict[system]}" in
        '0')
            koopa_cp "${dict[tmp_file]}" "${dict[file]}"
            ;;
        '1')
            koopa_cp --sudo "${dict[tmp_file]}" "${dict[file]}"
            ;;
    esac
    return 0
}

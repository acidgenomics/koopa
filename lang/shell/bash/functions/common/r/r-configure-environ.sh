#!/usr/bin/env bash

# FIXME Work on hardening these:
# > PAGER=${PAGER-'/usr/bin/less'}
# > R_BROWSER=${R_BROWSER-'/usr/bin/open'}
# > R_BZIPCMD=${R_BZIPCMD-'/usr/bin/bzip2'}
# > R_GZIPCMD=${R_GZIPCMD-'/usr/bin/gzip'}
# > R_PDFVIEWER=${R_PDFVIEWER-'/usr/bin/open'}
# > R_PRINTCMD=${R_PRINTCMD-'lpr'}
# > R_TEXI2DVICMD=${R_TEXI2DVICMD-${TEXI2DVI-'/usr/local/bin/texi2dvi'}}
# > R_UNZIPCMD=${R_UNZIPCMD-'/usr/bin/unzip'}
# > R_ZIPCMD=${R_ZIPCMD-'/usr/bin/zip'}

# NOTE RStudio PATH is now inconsistent with R due to breaking changes in
# internal 'SessionPath.cpp'.
#
# Consider filing an issue or pull request that looks for PATH defined
# in system 'Renviron', 'Renviron.site', or user '~/.R/Renviron' config files.
#
# See related:
# - https://github.com/rstudio/rstudio/blob/main/src/cpp/session/
#     modules/SessionPath.cpp
# - https://github.com/rstudio/rstudio/issues/10551
# - https://github.com/rstudio/rstudio/issues/10311

koopa_r_configure_environ() {
    # """
    # Configure 'Renviron.site' file.
    # @note Updated 2022-09-20.
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
    local app conf_dict dict i key keys lines path_arr
    local app_pc_path_arr pc_path_arr
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        ['cat']="$(koopa_locate_cat)"
        ['pkg_config']="$(koopa_locate_pkg_config)"
        ['r']="${1:?}"
        ['sort']="$(koopa_locate_sort)"
    )
    [[ -x "${app['cat']}" ]] || return 1
    [[ -x "${app['pkg_config']}" ]] || return 1
    [[ -x "${app['r']}" ]] || return 1
    [[ -x "${app['sort']}" ]] || return 1
    declare -A dict=(
        ['conda']="$(koopa_app_prefix 'conda')"
        ['koopa_prefix']="$(koopa_koopa_prefix)"
        ['r_prefix']="$(koopa_r_prefix "${app['r']}")"
        ['system']=0
        ['tmp_file']="$(koopa_tmp_file)"
        ['udunits2']="$(koopa_app_prefix 'udunits')"
    )
    koopa_assert_is_dir \
        "${dict['conda']}" \
        "${dict['r_prefix']}" \
        "${dict['udunits2']}"
    dict['file']="${dict['r_prefix']}/etc/Renviron.site"
    ! koopa_is_koopa_app "${app['r']}" && dict['system']=1
    koopa_alert "Configuring '${dict['file']}'."
    declare -A conf_dict
    lines=()
    lines+=(
        "R_LIBS_SITE=\${R_HOME}/site-library"
        "R_LIBS_USER=\${R_LIBS_SITE}"
    )
    # Set the 'PATH' string. Restricting path, so we don't mask compiler
    # binaries with virtual environment. This also greatly improves consistency
    # inside RStudio.
    path_arr=()
    # > case "${dict['system']}" in
    # >     '1')
    # >         path_arr+=('/usr/local/bin')
    # >         ;;
    # > esac
    path_arr+=(
        "${dict['koopa_prefix']}/bin"
        '/usr/bin'
        '/bin'
    )
    if koopa_is_macos
    then
        path_arr+=(
            '/Applications/quarto/bin'
            # > '/Applications/RStudio.app/Contents/MacOS'
            # > '/Applications/RStudio.app/Contents/MacOS/quarto/bin'
            # . '/Applications/RStudio.app/Contents/MacOS/quarto/bin/tools'
            '/Library/TeX/texbin'
            '/usr/local/MacGPG2/bin'
            '/opt/X11/bin'
        )
    fi
    # Set the 'PKG_CONFIG_PATH' string.
    declare -A app_pc_path_arr
    keys=(
        'curl'
        'fontconfig'
        'freetype'
        'fribidi'
        'gdal'
        'geos'
        'glib'
        'graphviz'
        'harfbuzz'
        'icu4c'
        'imagemagick'
        'jpeg'
        'lapack'
        'libgit2'
        'libjpeg-turbo'
        'libpng'
        'libssh2'
        'libtiff'
        # > 'libuv'
        'libxml2'
        'openblas'
        'openssl3'
        'pcre'
        'pcre2'
        'proj'
        'python'
        'readline'
        'sqlite'
        'xz'
        'zlib'
        'zstd'
    )
    for key in "${keys[@]}"
    do
        local prefix
        prefix="$(koopa_app_prefix "$key")"
        koopa_assert_is_dir "$prefix"
        app_pc_path_arr[$key]="$prefix"
    done
    for i in "${!app_pc_path_arr[@]}"
    do
        app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/lib"
    done
    if koopa_is_linux
    then
        app_pc_path_arr['glib']="${app_pc_path_arr['glib']}64"
        app_pc_path_arr['harfbuzz']="${app_pc_path_arr['harfbuzz']}64"
    fi
    for i in "${!app_pc_path_arr[@]}"
    do
        app_pc_path_arr[$i]="${app_pc_path_arr[$i]}/pkgconfig"
    done
    koopa_assert_is_dir "${app_pc_path_arr[@]}"
    pc_path_arr=()
    # > if [[ "${dict['system']}" -eq 1 ]]
    # > then
    # >     pc_path_arr+=('/usr/local/lib/pkgconfig')
    # > fi
    pc_path_arr+=("${app_pc_path_arr[@]}")
    # > if [[ "${dict['system']}" -eq 1 ]]
    # > then
    # >     local sys_pc_path_arr
    # >     # NOTE Likely want to include '/usr/bin/pkg-config' here also.
    # >     readarray -t sys_pc_path_arr <<< "$( \
    # >         "${app['pkg_config']}" --variable 'pc_path' 'pkg-config' \
    # >     )"
    # >     pc_path_arr+=("${sys_pc_path_arr[@]}")
    # > fi
    conf_dict['path']="$(printf '%s:' "${path_arr[@]}")"
    conf_dict['pkg_config_path']="$(printf '%s:' "${pc_path_arr[@]}")"
    lines+=(
        "PAGER=\${PAGER:-less}"
        "PATH=${conf_dict['path']}"
        "PKG_CONFIG_PATH=${conf_dict['pkg_config_path']}"
        "TZ=\${TZ:-America/New_York}"
        'R_BATCHSAVE=--no-save --no-restore'
        'R_PAPERSIZE=letter'
        "R_PAPERSIZE_USER=\${R_PAPERSIZE}"
        'R_UNZIPCMD=/usr/bin/unzip'
        'R_ZIPCMD=/usr/bin/zip'
    )
    if koopa_is_linux
    then
        lines+=(
            'R_BROWSER=/usr/bin/xdg-open'
            'R_PRINTCMD=/usr/bin/lpr'
        )
    elif koopa_is_macos
    then
        lines+=('R_MAX_NUM_DLLS=153')
    fi
    # data.table
    # --------------------------------------------------------------------------
    # Refer to 'data.table::getDTthreads' for more info.
    lines+=('R_DATATABLE_NUM_PROCS_PERCENT=100')
    # rcmdcheck
    # --------------------------------------------------------------------------
    # Options: "never", "error", "warning", "note".
    lines+=('RCMDCHECK_ERROR_ON=warning')
    # remotes
    # --------------------------------------------------------------------------
    lines+=(
        # Standalone mode. remotes will use the curl, git2r and pkgbuild
        # packages if they are installed to provide faster implementations for
        # some aspects of the install process. However if you are using remotes
        # to install or update these packages (or their reverse dependencies)
        # using them during installation may fail (particularly on Windows).
        'R_REMOTES_STANDALONE=true'
        # Always upgrade GitHub R packages, without prompting.
        # See 'remotes::update_packages()' for details.
        'R_REMOTES_UPGRADE=always'
    )
    # reticulate
    # --------------------------------------------------------------------------
    lines+=(
        # Ensure the default location of Miniconda is standardized.
        "RETICULATE_MINICONDA_PATH=${dict['conda']}"
        # Default path to virtual environments.
        # Check with 'virtualenv_list()'.
        # https://rstudio.github.io/reticulate/reference/virtualenv-tools.html
        "WORKON_HOME=\${HOME}/.virtualenvs"
    )
    # stringi
    # --------------------------------------------------------------------------
    lines+=(
        # Ensure usage of system ICU, insteading of building bundle from source.
        'STRINGI_DISABLE_ICU_BUNDLE=1'
        # Alternatively, ensure that ICU bundle is compiled from source.
        # > 'STRINGI_DISABLE_PKG_CONFIG=1'
    )
    # tools
    # --------------------------------------------------------------------------
    # These values are inherited by 'tools::R_user_dir()'.
    lines+=(
        "R_USER_CACHE_DIR=\${HOME}/.cache"
        "R_USER_CONFIG_DIR=\${HOME}/.config"
        "R_USER_DATA_DIR=\${HOME}/.local/share"
    )
    # units
    # --------------------------------------------------------------------------
    # The units package requires udunits2 to be installed.
    lines+=(
        "UDUNITS2_INCLUDE=${dict['udunits2']}/include"
        "UDUNITS2_LIBS=${dict['udunits2']}/lib"
    )
    if koopa_is_fedora_like
    then
        dict['oracle_ver']="$(koopa_app_json_version 'oracle-instant-client')"
        dict['oracle_ver']="$( \
            koopa_major_minor_version "${dict['oracle_ver']}" \
        )"
        # ROracle
        # ----------------------------------------------------------------------
        # This requires installation of the Oracle Database Instant Client.
        # Install with 'koopa install system oracle-instant-client'.
        lines+=(
            "OCI_VERSION=${dict['oracle_ver']}"
            "ORACLE_HOME=/usr/lib/oracle/\${OCI_VERSION}/client64"
            "OCI_INC=/usr/include/oracle/\${OCI_VERSION}/client64"
            "OCI_LIB=\${ORACLE_HOME}/lib"
            "PATH=\${PATH}:\${ORACLE_HOME}/bin"
            "TNS_ADMIN=\${ORACLE_HOME}/network/admin"
        )
    fi
    # Bioconductor build system (BBS) recommendations.
    # See also:
    # - https://github.com/Bioconductor/BBS/blob/master/3.16/Renviron.bioc
    # - https://github.com/Bioconductor/bioconductor_docker
    lines+=(
        # > '_R_CHECK_LENGTH_1_CONDITION_=verbose'
        # > '_R_CHECK_LENGTH_1_LOGIC2_=verbose'
        # > '_R_CHECK_TIMINGS_=0'
        # > '_R_CLASS_MATRIX_ARRAY_=true'
        # > '_R_S3_METHOD_LOOKUP_BASEENV_AFTER_GLOBALENV_=true'
        '_R_CHECK_EXECUTABLES_=false'
        '_R_CHECK_EXECUTABLES_EXCLUSIONS_=false'
        "_R_CHECK_LENGTH_1_CONDITION_=package:_R_CHECK_PACKAGE_NAME_,\
abort,verbose"
        "_R_CHECK_LENGTH_1_LOGIC2_=package:_R_CHECK_PACKAGE_NAME_,\
abort,verbose"
        '_R_CHECK_S3_METHODS_NOT_REGISTERED_=true'
        'R_DEFAULT_INTERNET_TIMEOUT=600'
    )
    # Additional useful build environment variables.
    lines+=(
        # Avoid issue with file timestamp check:
        #     > N  checking for future file timestamps
        #     >    unable to verify current time
        # https://stackoverflow.com/questions/63613301/
        '_R_CHECK_SYSTEM_CLOCK_=0'
        # Don't truncate R CMD check output.
        # See also:
        # - https://twitter.com/michael_chirico/status/1193831562724331520
        # - https://yihui.name/en/2017/12/last-13-lines-of-output/
        '_R_CHECK_TESTS_NLINES_=0'
    )
    if koopa_is_linux
    then
        lines+=(
            # Debian (and its derivatives) impose a set of compiler flags to
            # prevent some known security issues with compiled code. These flags
            # then become defaults for R as well (see eg '/etc/R/Makeconf'), but
            # nevertheless confuse R as warnings get triggered.  Users, on the
            # other hand, are often stumped about these. So with this variable
            # we declare these options as known for the local checks on the
            # machine this file is on. See Section 8 of the R Internals manual
            # for many more options.
            "_R_CHECK_COMPILATION_FLAGS_KNOWN_=-Wformat \
-Werror=format-security -Wdate-time"
        )
    fi
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    case "${dict['system']}" in
        '0')
            koopa_rm "${dict['file']}"
            koopa_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
        '1')
            koopa_rm --sudo "${dict['file']}"
            koopa_sudo_write_string \
                --file="${dict['file']}" \
                --string="${dict['string']}"
            ;;
    esac
    return 0
}

#!/usr/bin/env bash

koopa_r_configure_environ() {
    # """
    # Configure 'Renviron.site' file.
    # @note Updated 2023-09-06.
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
    local -A app bool conf_dict dict
    local -a lines path_arr
    lines=()
    path_arr=()
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    app['sort']="$(koopa_locate_sort --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    dict['bin_prefix']="$(koopa_bin_prefix)"
    dict['r_prefix']="$(koopa_r_prefix "${app['r']}")"
    koopa_assert_is_dir "${dict['r_prefix']}"
    if [[ "${bool['system']}" -eq 1 ]]
    then
        lines+=(
            'R_BATCHSAVE=--no-save --no-restore'
            "R_LIBS_SITE=\${R_HOME}/site-library"
            "R_LIBS_USER=\${R_LIBS_SITE}"
            'R_PAPERSIZE=letter'
            "R_PAPERSIZE_USER=\${R_PAPERSIZE}"
            "TZ=\${TZ:-America/New_York}"
        )
    fi
    # Set the 'PATH' string. Restricting path, so we don't mask compiler
    # binaries with virtual environment. This also greatly improves consistency
    # inside RStudio.
    if koopa_is_linux
    then
        path_arr+=(
            '/usr/lib/rstudio-server/bin/quarto/bin'
            '/usr/lib/rstudio-server/bin/quarto/bin/tools'
            '/usr/lib/rstudio-server/bin/postback'
        )
    elif koopa_is_macos
    then
        path_arr+=(
            '/Applications/RStudio.app/Contents/Resources/app/quarto/bin'
            '/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools'
            '/Applications/RStudio.app/Contents/Resources/app/bin/postback'
        )
    fi
    if [[ "${bool['system']}" -eq 0 ]] || koopa_is_macos
    then
        path_arr+=("${dict['bin_prefix']}")
    fi
    path_arr+=('/usr/bin' '/bin')
    if koopa_is_macos
    then
        path_arr+=(
            '/Library/TeX/texbin'
            '/usr/local/MacGPG2/bin'
            '/opt/X11/bin'
        )
    fi
    conf_dict['path']="$(printf '%s:' "${path_arr[@]}")"
    lines+=("PATH=${conf_dict['path']}")
    if koopa_is_macos
    then
        # This setting is covered in our Rprofile.
        # > if [[ "${bool['system']}" -eq 1 ]]
        # > then
        # >     lines+=('R_COMPILE_AND_INSTALL_PACKAGES=never')
        # > fi
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
    )
    # tools
    # --------------------------------------------------------------------------
    # These values are inherited by 'tools::R_user_dir()'.
    lines+=(
        "R_USER_CACHE_DIR=\${HOME}/.cache"
        "R_USER_CONFIG_DIR=\${HOME}/.config"
        "R_USER_DATA_DIR=\${HOME}/.local/share"
    )
    # vroom
    # --------------------------------------------------------------------------
    # Default connection size of 131072 is often too small. Increasing by 4x.
    # See also:
    # - https://github.com/tidyverse/vroom/issues/364
    # - https://community.rstudio.com/t/
    #     vroom-connection-size-needs-increasing/34560/6
    lines+=("VROOM_CONNECTION_SIZE=524288")
    if koopa_is_fedora_like
    then
        dict['oracle_ver']="$( \
            koopa_app_json_version 'oracle-instant-client' \
        )"
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
    dict['file']="${dict['r_prefix']}/etc/Renviron.site"
    # Ensure we handle Debian configuration files in '/etc/R'.
    if [[ -L "${dict['file']}" ]]
    then
        dict['realfile']="$(koopa_realpath "${dict['file']}")"
        if [[ "${dict['realfile']}" == '/etc/R/Renviron.site' ]]
        then
            dict['file']="${dict['realfile']}"
        fi
    fi
    koopa_alert_info "Modifying '${dict['file']}'."
    dict['string']="$(koopa_print "${lines[@]}" | "${app['sort']}")"
    case "${bool['system']}" in
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

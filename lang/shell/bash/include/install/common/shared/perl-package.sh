#!/usr/bin/env bash

# FIXME Alternatively can use cpan -j with our config file here?

main() {
    # """
    # Install Perl package.
    # @note Updated 2023-03-07.
    #
    # Confirm library configuration with 'perl -V' and check '@INC' variable.
    #
    # @section ack installation:
    #
    # File::Next is required for ack.
    # https://github.com/beyondgrep/ack2/issues/459
    #
    # @seealso
    # - https://www.cpan.org/modules/INSTALL.html
    # - https://perldoc.perl.org/ExtUtils::MakeMaker
    # - https://metacpan.org/pod/local::lib
    # - https://www.perl.com/article/4/2013/3/27/
    #     How-to-install-a-specific-version-of-a-Perl-module-with-CPAN/
    # - https://stackoverflow.com/questions/18458194/
    # - https://stackoverflow.com/questions/41527057/
    # - https://kb.iu.edu/d/baiu
    # - http://alumni.soe.ucsc.edu/~you/notes/perl-module-install.html
    # - https://docstore.mik.ua/orelly/weblinux2/modperl/ch03_09.htm
    # - https://blogs.iu.edu/ncgas/2019/05/30/installing-perl-modules-locally/
    # - https://stackoverflow.com/questions/540640/
    # """
    local app bin_file bin_files dict
    koopa_assert_has_no_args "$#"
    koopa_activate_app --build-only 'perl'
    declare -A app=(
        ['bash']="$(koopa_locate_bash)"
        ['bzip2']="$(koopa_locate_bzip2)"
        ['cpan']="$(koopa_locate_cpan)"
        ['gpg']="$(koopa_locate_gpg)"
        ['gzip']="$(koopa_locate_gzip)"
        ['less']="$(koopa_locate_less)"
        ['make']="$(koopa_locate_make)"
        ['patch']="$(koopa_locate_patch)"
        ['perl']="$(koopa_locate_perl)"
        ['tar']="$(koopa_locate_tar)"
        ['unzip']="$(koopa_locate_unzip)"
        ['wget']="$(koopa_locate_wget)"
    )
    [[ -x "${app['bash']}" ]] || return 1
    [[ -x "${app['bzip2']}" ]] || return 1
    [[ -x "${app['cpan']}" ]] || return 1
    [[ -x "${app['gpg']}" ]] || return 1
    [[ -x "${app['gzip']}" ]] || return 1
    [[ -x "${app['less']}" ]] || return 1
    [[ -x "${app['make']}" ]] || return 1
    [[ -x "${app['patch']}" ]] || return 1
    [[ -x "${app['perl']}" ]] || return 1
    [[ -x "${app['tar']}" ]] || return 1
    [[ -x "${app['unzip']}" ]] || return 1
    [[ -x "${app['wget']}" ]] || return 1
    declare -A dict=(
        ['cpan_prefix']="$(koopa_init_dir 'cpan')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    # Harden against any undesirable variables set by user.
    unset -v \
        PERL5LIB \
        PERL_BASE \
        PERL_LOCAL_LIB_ROOT \
        PERL_MB_OPT \
        PERL_MM_OPT
    dict['cpan_config_file']="${dict['cpan_prefix']}/CPAN/MyConfig.pm"
    read -r -d '' "dict[cpan_config_string]" << END || true
\$CPAN::Config = {
  'allow_installing_module_downgrades' => q[no],
  'allow_installing_outdated_dists' => q[yes],
  'applypatch' => q[],
  'auto_commit' => q[0],
  'build_cache' => q[100],
  'build_dir' => q[${dict['cpan_prefix']}/build],
  'build_dir_reuse' => q[0],
  'build_requires_install_policy' => q[yes],
  'bzip2' => q[${app['bzip2']}],
  'cache_metadata' => q[0],
  'check_sigs' => q[0],
  'cleanup_after_install' => q[1],
  'colorize_output' => q[0],
  'commandnumber_in_prompt' => q[1],
  'connect_to_internet_ok' => q[1],
  'cpan_home' => q[${dict['cpan_prefix']}],
  'ftp_passive' => q[1],
  'ftp_proxy' => q[],
  'getcwd' => q[cwd],
  'gpg' => q[${app['gpg']}],
  'gzip' => q[${app['gzip']}],
  'halt_on_failure' => q[1],
  'histfile' => q[${dict['cpan_prefix']}/histfile],
  'histsize' => q[100],
  'http_proxy' => q[],
  'inactivity_timeout' => q[0],
  'index_expire' => q[1],
  'inhibit_startup_message' => q[1],
  'keep_source_where' => q[${dict['cpan_prefix']}/sources],
  'load_module_verbosity' => q[v],
  'make' => q[${app['make']}],
  'make_arg' => q[-j${dict['jobs']}],
  'make_install_arg' => q[-j${dict['jobs']}],
  'make_install_make_command' => q[${app['make']}],
  'makepl_arg' => q[INSTALL_BASE=${dict['prefix']}],
  'mbuild_arg' => q[],
  'mbuild_install_arg' => q[],
  'mbuild_install_build_command' => q[./Build],
  'mbuildpl_arg' => q[--install_base ${dict['prefix']}],
  'no_proxy' => q[],
  'pager' => q[${app['less']} -R],
  'patch' => q[${app['patch']}],
  'perl5lib_verbosity' => q[v],
  'prefer_external_tar' => q[1],
  'prefer_installer' => q[MB],
  'prefs_dir' => q[${dict['cpan_prefix']}/prefs],
  'prerequisites_policy' => q[follow],
  'pushy_https' => q[1],
  'recommends_policy' => q[1],
  'scan_cache' => q[never],
  'shell' => q[${app['bash']}],
  'show_unparsable_versions' => q[0],
  'show_upload_date' => q[0],
  'show_zero_versions' => q[0],
  'suggests_policy' => q[0],
  'tar' => q[${app['tar']}],
  'tar_verbosity' => q[vv],
  'term_is_latin' => q[1],
  'term_ornaments' => q[1],
  'test_report' => q[0],
  'trust_test_report_history' => q[0],
  'unzip' => q[${app['unzip']}],
  'urllist' => [q[http://www.cpan.org/]],
  'use_prompt_default' => q[1],
  'use_sqlite' => q[0],
  'version_timeout' => q[15],
  'wget' => q[${app['wget']}],
  'yaml_load_code' => q[0],
  'yaml_module' => q[YAML],
};
1;
__END__
END
    koopa_write_string \
        --file="${dict['cpan_config_file']}" \
        --string="${dict['cpan_config_string']}"
    dict['name2']="${dict['name']}"
    dict['version2']="${dict['version']}"
    case "${dict['name']}" in
        'ack')
            # App::Ack.
            dict['author']='PETDANCE'
            dict['version2']="v${dict['version']}"
            ;;
        # > 'cpanminus')
        # >     # App::cpanminus.
        # >     dict['author']='MIYAGAWA'
        # >     dict['name2']='App-cpanminus'
        # >     ;;
        'exiftool')
            # Image::ExifTool.
            dict['author']='EXIFTOOL'
            dict['name2']='Image-ExifTool'
            ;;
        'rename')
            # File::Rename.
            dict['author']='RMBARKER'
            dict['name2']='File-Rename'
            ;;
        *)
            koopa_stop "Unsupported Perl package: '${dict['name']}'."
            ;;
    esac
    dict['perl_ver']="$(koopa_get_version "${app['perl']}")"
    dict['perl_maj_ver']="$(koopa_major_version "${dict['perl_ver']}")"
    dict['lib_prefix']="${dict['prefix']}/lib/perl${dict['perl_maj_ver']}"
    koopa_print_env
    "${app['cpan']}" \
        -j "${dict['cpan_config_file']}" \
        "${dict['author']}/${dict['name2']}-${dict['version2']}.tar.gz"
    koopa_assert_is_dir "${dict['lib_prefix']}"
    # Ensure we burn Perl library path into executables. This will add a line
    # directly under the shebang.
    # > dict['lib_string']="BEGIN { unshift @INC, \"${dict['lib_prefix']}\"; }"
    dict['lib_string']="use lib \"${dict['lib_prefix']}\";"
    readarray -t bin_files <<< "$( \
        koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['prefix']}/bin" \
            --type='f' \
    )"
    koopa_assert_is_array_non_empty "${bin_files[@]:-}"
    koopa_assert_is_file "${bin_files[@]}"
    for bin_file in "${bin_files[@]}"
    do
        koopa_insert_at_line_number \
            --file="$bin_file" \
            --line-number=2 \
            --string="${dict['lib_string']}"
    done
    return 0
}

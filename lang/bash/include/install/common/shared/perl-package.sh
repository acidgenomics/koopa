#!/usr/bin/env bash

# NOTE How to disable version update notice?
# NOTE How to save 'man1', 'man3' to 'share/man' instead of 'man'?

main() {
    # """
    # Install Perl package.
    # @note Updated 2023-04-24.
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
    local -A app dict
    local -a bin_files
    local bin_file
    koopa_activate_app --build-only 'perl'
    app['bash']="$(koopa_locate_bash)"
    app['bzip2']="$(koopa_locate_bzip2)"
    app['cpan']="$(koopa_locate_cpan)"
    app['gpg']="$(koopa_locate_gpg)"
    app['gzip']="$(koopa_locate_gzip)"
    app['less']="$(koopa_locate_less)"
    app['make']="$(koopa_locate_make)"
    app['patch']="$(koopa_locate_patch)"
    app['perl']="$(koopa_locate_perl)"
    app['tar']="$(koopa_locate_tar)"
    app['unzip']="$(koopa_locate_unzip)"
    app['wget']="$(koopa_locate_wget)"
    koopa_assert_is_executable "${app[@]}"
    dict['cpan_prefix']="$(koopa_init_dir 'cpan')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
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
    export PERL5LIB="${dict['lib_prefix']}"
    koopa_print_env
    case "${dict['name']}" in
        'ack')
            "${app['cpan']}" \
                -j "${dict['cpan_config_file']}" \
                'File::Next'
            ;;
    esac
    "${app['cpan']}" \
        -j "${dict['cpan_config_file']}" \
        "${dict['author']}/${dict['name2']}-${dict['version2']}.tar.gz"
    koopa_assert_is_dir "${dict['lib_prefix']}"
    # Ensure we burn Perl library path into executables.
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

#!/usr/bin/env bash

koopa::activate_conda() { # {{{1
    _koopa_activate_conda "$@"
}

koopa::activate_go() { # {{{1
    _koopa_activate_go "$@"
}

koopa::activate_llvm() { # {{{1
    _koopa_activate_llvm "$@"
}

koopa::activate_openjdk() { # {{{1
    _koopa_activate_openjdk "$@"
}

koopa::activate_opt_prefix() { # {{{1
    _koopa_activate_opt_prefix "$@"
}

koopa::activate_perl_packages() { # {{{1
    _koopa_activate_perl_packages "$@"
}

koopa::activate_prefix() { # {{{1
    _koopa_activate_prefix "$@"
}

koopa::activate_rust() { # {{{1
    _koopa_activate_rust "$@"
}

koopa::activate_starship() { # {{{1
    _koopa_activate_starship "$@"
}

koopa::add_config_link() { # {{{1
    _koopa_add_config_link "$@"
}

koopa::add_to_manpath_end() { # {{{1
    _koopa_add_to_manpath_end "$@"
}

koopa::add_to_manpath_start() { # {{{1
    _koopa_add_to_manpath_start "$@"
}

koopa::add_to_path_end() { # {{{1
    _koopa_add_to_path_end "$@"
}

koopa::add_to_path_start() { # {{{1
    _koopa_add_to_path_start "$@"
}

koopa::add_to_pkg_config_path_end() { # {{{1
    _koopa_add_to_pkg_config_path_end "$@"
}

koopa::add_to_pkg_config_path_start() { # {{{1
    _koopa_add_to_pkg_config_path_start "$@"
}

koopa::alert() { # {{{1
    _koopa_alert "$@"
}

koopa::alert_coffee_time() { # {{{1
    _koopa_alert_coffee_time "$@"
}

koopa::alert_info() { # {{{1
    _koopa_alert_info "$@"
}

koopa::alert_note() { # {{{1
    _koopa_alert_note "$@"
}

koopa::alert_restart() { # {{{1
    _koopa_alert_restart "$@"
}

koopa::alert_success() { # {{{1
    _koopa_alert_success "$@"
}

koopa::app_prefix() { # {{{1
    _koopa_app_prefix "$@"
}

koopa::arch() { # {{{1
    _koopa_arch "$@"
}

koopa::aspera_prefix() { # {{{1
    _koopa_aspera_prefix "$@"
}

koopa::bcbio_tools_prefix() { # {{{1
    _koopa_bcbio_tools_prefix "$@"
}

koopa::boolean_nounset() { # {{{1
    _koopa_boolean_nounset "$@"
}

koopa::camel_case_simple() { # {{{1
    _koopa_camel_case_simple "$@"
}

koopa::cd() { # {{{1
    _koopa_cd "$@"
}

koopa::conda_env() { # {{{1
    _koopa_conda_env "$@"
}

koopa::conda_prefix() { # {{{1
    _koopa_conda_prefix "$@"
}

koopa::config_prefix() { # {{{1
    _koopa_config_prefix "$@"
}

koopa::cpu_count() { # {{{1
    _koopa_cpu_count "$@"
}

koopa::data_disk_link_prefix() { # {{{1
    _koopa_data_disk_link_prefix "$@"
}

koopa::deactivate_conda() { # {{{1
    _koopa_deactivate_conda "$@"
}

koopa::deactivate_envs() { # {{{1
    _koopa_deactivate_envs "$@"
}

koopa::deactivate_venv() { # {{{1
    _koopa_deactivate_venv "$@"
}

koopa::distro_prefix() { # {{{
    _koopa_distro_prefix "$@"
}

koopa::dl() { # {{{1
    _koopa_dl "$@"
}

koopa::docker_prefix() { # {{{1
    _koopa_docker_prefix "$@"
}

koopa::docker_private_prefix() { # {{{1
    _koopa_docker_private_prefix "$@"
}

koopa::dotfiles_prefix() { # {{{1
    _koopa_dotfiles_prefix "$@"
}

koopa::dotfiles_private_prefix() { # {{{1
    _koopa_dotfiles_private_prefix "$@"
}

koopa::emacs_prefix() { # {{{1
    _koopa_emacs_prefix "$@"
}

koopa::ensembl_perl_api_prefix() { # {{{1
    _koopa_ensembl_perl_api_prefix "$@"
}

koopa::exec_dir() { # {{{1
    _koopa_exec_dir "$@"
}

koopa::expr() { # {{{1
    _koopa_expr "$@"
}

koopa::fzf_prefix() { # {{{1
    _koopa_fzf_prefix "$@"
}

koopa::git_branch() { # {{{1
    _koopa_git_branch "$@"
}

koopa::go_gopath() { # {{{1
    _koopa_go_gopath "$@"
}

koopa::go_prefix() { # {{{1
    _koopa_go_prefix "$@"
}

koopa::group() { # {{{1
    _koopa_group "$@"
}

koopa::group_id() { # {{{1
    _koopa_group_id "$@"
}

koopa::gsub() { # {{{1
    _koopa_gsub "$@"
}

koopa::has_gnu() { # {{{1
    _koopa_has_gnu "$@"
}

koopa::has_gnu_binutils() { # {{{1
    _koopa_has_gnu_binutils "$@"
}

koopa::has_gnu_coreutils() { # {{{1
    _koopa_has_gnu_coreutils "$@"
}

koopa::has_gnu_findutils() { # {{{1
    _koopa_has_gnu_findutils "$@"
}

koopa::has_gnu_rsync() { # {{{1
    _koopa_has_gnu_rsync "$@"
}

koopa::has_gnu_sed() { # {{{1
    _koopa_has_gnu_sed "$@"
}

koopa::has_gnu_tar() { # {{{1
    _koopa_has_gnu_tar "$@"
}

koopa::h1() { # {{{1
    _koopa_h1 "$@"
}

koopa::h2() { # {{{1
    _koopa_h2 "$@"
}

koopa::h3() { # {{{1
    _koopa_h3 "$@"
}

koopa::h4() { # {{{1
    _koopa_h4 "$@"
}

koopa::h5() { # {{{1
    _koopa_h5 "$@"
}

koopa::h6() { # {{{1
    _koopa_h6 "$@"
}

koopa::h7() { # {{{1
    _koopa_h7 "$@"
}

koopa::homebrew_cellar_prefix() { # {{{1
    _koopa_homebrew_cellar_prefix "$@"
}

koopa::homebrew_prefix() { # {{{1
    _koopa_homebrew_prefix "$@"
}

koopa::homebrew_ruby_packages_prefix() { # {{{1
    _koopa_homebrew_ruby_packages_prefix "$@"
}

koopa::hostname() { # {{{1
    _koopa_hostname "$@"
}

koopa::host_id() { # {{{1
    _koopa_host_id "$@"
}

koopa::include_prefix() { # {{{1
    _koopa_include_prefix "$@"
}

koopa::invalid_arg() { # {{{1
    _koopa_invalid_arg "$@"
}

koopa::is_alias() { # {{{1
    _koopa_is_alias "$@"
}

koopa::is_alpine() { # {{{1
    _koopa_is_alpine "$@"
}

koopa::is_amzn() { # {{{1
    _koopa_is_amzn "$@"
}

koopa::is_arch() { # {{{1
    _koopa_is_arch "$@"
}

koopa::is_aws() { # {{{1
    _koopa_is_aws "$@"
}

koopa::is_azure() { # {{{1
    _koopa_is_azure "$@"
}

koopa::is_centos() { # {{{1
    _koopa_is_centos "$@"
}

koopa::is_centos_like() { # {{{1
    _koopa_is_centos_like "$@"
}

koopa::is_conda_active() { # {{{1
    _koopa_is_conda_active "$@"
}

koopa::is_debian() { # {{{1
    _koopa_is_debian "$@"
}

koopa::is_debian_like() { # {{{1
    _koopa_is_debian_like "$@"
}

koopa::is_fedora() { # {{{1
    _koopa_is_fedora "$@"
}

koopa::is_fedora_like() { # {{{1
    _koopa_is_fedora_like "$@"
}

koopa::is_git() { # {{{1
    _koopa_is_git "$@"
}

koopa::is_git_clean() { # {{{1
    _koopa_is_git_clean "$@"
}

koopa::is_git_toplevel() { # {{{1
    _koopa_is_git_toplevel "$@"
}

koopa::is_host() { # {{{1
    _koopa_is_host "$@"
}

koopa::is_installed() { # {{{1
    _koopa_is_installed "$@"
}

koopa::is_interactive() { # {{{1
    _koopa_is_installed "$@"
}

koopa::is_linux() { # {{{1
    _koopa_is_linux "$@"
}

koopa::is_local_install() { # {{{1
    _koopa_is_local_install "$@"
}

koopa::is_macos() { # {{{1
    _koopa_is_macos "$@"
}

koopa::is_opensuse() { # {{{1
    _koopa_is_opensuse "$@"
}

koopa::is_os() { # {{{1
    _koopa_is_os "$@"
}

koopa::is_os_like() { # {{{1
    _koopa_is_os_like "$@"
}

koopa::is_os_version() { # {{{1
    _koopa_is_os_version "$@"
}

koopa::is_raspbian() { # {{{1
    _koopa_is_raspbian "$@"
}

koopa::is_remote() { # {{{1
    _koopa_is_remote "$@"
}

koopa::is_rhel() { # {{{1
    _koopa_is_rhel "$@"
}

koopa::is_rhel_like() { # {{{1
    _koopa_is_rhel_like "$@"
}

koopa::is_rhel_ubi() { # {{{1
    _koopa_is_rhel_ubi "$@"
}

koopa::is_rhel_7_like() { # {{{1
    _koopa_is_rhel_7_like "$@"
}

koopa::is_rhel_8_like() { # {{{1
    _koopa_is_rhel_8_like "$@"
}

koopa::is_root() { # {{{1
    _koopa_is_root "$@"
}

koopa::is_rstudio() { # {{{1
    _koopa_is_rstudio "$@"
}

koopa::is_set_nounset() { # {{{1
    _koopa_is_set_nounset "$@"
}

koopa::is_shared_install() { # {{{1
    _koopa_is_shared_install "$@"
}

koopa::is_subshell() { # {{{1
    _koopa_is_subshell "$@"
}

koopa::is_tmux() { # {{{1
    _koopa_is_tmux "$@"
}

koopa::is_tty() { # {{{1
    _koopa_is_tty "$@"
}

koopa::is_ubuntu() { # {{{1
    _koopa_is_ubuntu "$@"
}

koopa::is_ubuntu_like() { # {{{1
    _koopa_is_ubuntu_like "$@"
}

koopa::is_venv_active() { # {{{1
    _koopa_is_venv_active "$@"
}

koopa::java_prefix() { # {{{1
    _koopa_java_prefix "$@"
}

koopa::kebab_case_simple() { # {{{1
    _koopa_kebab_case_simple "$@"
}

koopa::lmod_prefix() { # {{{1
    _koopa_lmod_prefix "$@"
}

koopa::local_data_prefix() { # {{{1
    _koopa_local_data_prefix "$@"
}

koopa::lowercase() { # {{{1
    _koopa_lowercase "$@"
}

koopa::macos_version() { # {{{1
    _koopa_macos_version "$@"
}

koopa::major_version() { # {{{1
    _koopa_major_version "$@"
}

koopa::major_minor_version() { # {{{1
    _koopa_major_minor_version "$@"
}

koopa::major_minor_patch_version() { # {{{1
    _koopa_major_minor_patch_version "$@"
}

koopa::make_prefix() { # {{{1
    _koopa_make_prefix "$@"
}

koopa::mem_gb() { # {{{1
    _koopa_mem_gb "$@"
}

koopa::missing_arg() { # {{{1
    _koopa_missing_arg "$@"
}

koopa::msigdb_prefix() { # {{{1
    _koopa_msigdb_prefix "$@"
}

koopa::monorepo_prefix() { # {{{1
    _koopa_monorepo_prefix "$@"
}

koopa::ngettext() { # {{{1
    _koopa_ngettext "$@"
}

koopa::openjdk_prefix() { # {{{1
    _koopa_openjdk_prefix "$@"
}

koopa::opt_prefix() { # {{{1
    _koopa_opt_prefix "$@"
}

koopa::os_codename() { # {{{1
    _koopa_os_codename "$@"
}

koopa::os_id() { # {{{1
    _koopa_os_id "$@"
}

koopa::os_string() { # {{{1
    _koopa_os_string "$@"
}

koopa::parent_dir() { # {{{1
    _koopa_parent_dir "$@"
}

koopa::perl_packages_prefix() { # {{{1
    _koopa_perl_packages_prefix "$@"
}

koopa::perlbrew_prefix() { # {{{1
    _koopa_perlbrew_prefix "$@"
}

koopa::prefix() { # {{{1
    _koopa_prefix "$@"
}

koopa::prompt() { # {{{1
    _koopa_prompt "$@"
}

koopa::print() { # {{{1
    _koopa_print "$@"
}

koopa::print_black() { # {{{1
    _koopa_print_black "$@"
}

koopa::print_black_bold() { # {{{1
    _koopa_print_black_bold "$@"
}

koopa::print_blue() { # {{{1
    _koopa_print_blue "$@"
}

koopa::print_blue_bold() { # {{{1
    _koopa_print_blue_bold "$@"
}

koopa::print_cyan() { # {{{1
    _koopa_print_cyan "$@"
}

koopa::print_cyan_bold() { # {{{1
    _koopa_print_cyan_bold "$@"
}

koopa::print_default() { # {{{1
    _koopa_print_default "$@"
}

koopa::print_default_bold() { # {{{1
    _koopa_print_default_bold "$@"
}

koopa::print_green() { # {{{1
    _koopa_print_green "$@"
}

koopa::print_green_bold() { # {{{1
    _koopa_print_green_bold "$@"
}

koopa::print_magenta() { # {{{1
    _koopa_print_magenta "$@"
}

koopa::print_magenta_bold() { # {{{1
    _koopa_print_magenta_bold "$@"
}

koopa::print_red() { # {{{1
    _koopa_print_red "$@"
}

koopa::print_red_bold() { # {{{1
    _koopa_print_red_bold "$@"
}

koopa::print_yellow() { # {{{1
    _koopa_print_yellow "$@"
}

koopa::print_yellow_bold() { # {{{1
    _koopa_print_yellow_bold "$@"
}

koopa::print_white() { # {{{1
    _koopa_print_white "$@"
}

koopa::print_white_bold() { # {{{1
    _koopa_print_white_bold "$@"
}

koopa::pyenv_prefix() { # {{{1
    _koopa_pyenv_prefix "$@"
}

koopa::python() { # {{{1
    _koopa_python "$@"
}

koopa::python_packages_prefix() { # {{{1
    _koopa_python_packages_prefix "$@"
}

koopa::python_system_packages_prefix() { # {{{1
    _koopa_python_system_packages_prefix "$@"
}

koopa::r() { # {{{1
    _koopa_r "$@"
}

koopa::r_packages_prefix() { # {{{1
    _koopa_r_packages_prefix "$@"
}

koopa::rbenv_prefix() { # {{{1
    _koopa_rbenv_prefix "$@"
}

koopa::realpath() { # {{{1
    _koopa_realpath "$@"
}

koopa::refdata_prefix() { # {{{1
    _koopa_refdata_prefix "$@"
}

koopa::remove_from_manpath() { # {{{1
    _koopa_remove_from_manpath "$@"
}

koopa::remove_from_path() { # {{{1
    _koopa_remove_from_path "$@"
}

koopa::ruby_api_version() { # {{{1
    _koopa_ruby_api_version "$@"
}

koopa::rust_packages_prefix() { # {{{1
    _koopa_rust_packages_prefix "$@"
}

koopa::rustup_prefix() { # {{{1
    _koopa_rustup_prefix "$@"
}

koopa::scripts_private_prefix() { # {{{1
    _koopa_scripts_private_prefix "$@"
}

koopa::shell() { # {{{1
    _koopa_shell "$@"
}

koopa::snake_case_simple() { # {{{1
    _koopa_snake_case_simple "$@"
}

koopa::source_dir() { # {{{1
    _koopa_source_dir "$@"
}

koopa::status_fail() { # {{{1
    _koopa_status_fail "$@"
}

koopa::status_note() { # {{{1
    _koopa_status_note "$@"
}

koopa::status_ok() { # {{{1
    _koopa_status_ok "$@"
}

koopa::stop() { # {{{1
    _koopa_stop "$@"
}

koopa::str_match() { # {{{1
    _koopa_str_match "$@"
}

koopa::str_match_fixed() { # {{{1
    _koopa_str_match_fixed "$@"
}

koopa::str_match_perl() { # {{{1
    _koopa_str_match_perl "$@"
}

koopa::str_match_posix() { # {{{1
    _koopa_str_match_posix "$@"
}

koopa::str_match_regex() { # {{{1
    _koopa_str_match_regex "$@"
}

koopa::strip_left() { # {{{1
    _koopa_strip_left "$@"
}

koopa::strip_right() { # {{{1
    _koopa_strip_right "$@"
}

koopa::strip_trailing_slash() { # {{{1
    _koopa_strip_trailing_slash "$@"
}

koopa::sub() { # {{{1
    _koopa_sub "$@"
}

koopa::tests_prefix() { # {{{1
    _koopa_tests_prefix "$@"
}

koopa::today() { # {{{1
    _koopa_today "$@"
}

koopa::trim_ws() { # {{{1
    _koopa_trim_ws "$@"
}

koopa::user() { # {{{1
    _koopa_user "$@"
}

koopa::user_id() { # {{{1
    _koopa_user_id "$@"
}

koopa::variable() { # {{{1
    _koopa_variable "$@"
}

koopa::venv() { # {{{1
    _koopa_venv "$@"
}

koopa::venv_prefix() { # {{{1
    _koopa_venv_prefix "$@"
}

koopa::warning() { # {{{1
    _koopa_warning "$@"
}

koopa::which() { # {{{1
    _koopa_which "$@"
}

koopa::which_realpath() { # {{{1
    _koopa_which_realpath "$@"
}

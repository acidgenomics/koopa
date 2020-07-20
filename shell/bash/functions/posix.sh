#!/usr/bin/env bash

# FIXME MAKE ALL FUNCTIONS THAT REQUIRE THIS POSIX.
koopa::_ansi_escape() {
    __koopa_ansi_escape "$@"
}

# FIXME MAKE ALL FUNCTIONS THAT REQUIRE THIS POSIX.
koopa::_msg() {
    __koopa_msg "$@"
}

koopa::activate_openjdk() {
    _koopa_activate_openjdk "$@"
}

koopa::activate_rust() {
    _koopa_activate_rust "$@"
}

koopa::activate_conda() {
    _koopa_activate_conda "$@"
}

koopa::activate_go() {
    _koopa_activate_go "$@"
}

koopa::add_config_link() { # {{{1
    _koopa_add_config_link "$@"
}

koopa::add_to_manpath_end() {
    _koopa_add_to_manpath_end "$@"
}

koopa::add_to_manpath_start() {
    _koopa_add_to_manpath_start "$@"
}

koopa::add_to_path_end() {
    _koopa_add_to_path_end "$@"
}

koopa::add_to_path_start() {
    _koopa_add_to_path_start "$@"
}

koopa::add_to_pkg_config_path_end() {
    _koopa_add_to_pkg_config_path_end "$@"
}

koopa::add_to_pkg_config_path_start() {
    _koopa_add_to_pkg_config_path_start "$@"
}

koopa::app_prefix() {
    _koopa_app_prefix "$@"
}

koopa::aspera_prefix() {
    _koopa_aspera_prefix "$@"
}

koopa::autojump_prefix() {
    _koopa_autojump_prefix "$@"
}

koopa::bcbio_prefix() {
    _koopa_bcbio_prefix "$@"
}

koopa::boolean_nounset() {
    _koopa_boolean_nounset "$@"
}

koopa::cd() {
    _koopa_cd "$@"
}

koopa::cellar_prefix() {
    _koopa_cellar_prefix "$@"
}

koopa::conda_env() {
    _koopa_conda_env "$@"
}

koopa::conda_prefix() {
    _koopa_conda_prefix "$@"
}

koopa::config_prefix() {
    _koopa_config_prefix "$@"
}

koopa::cpu_count() {
    _koopa_cpu_count "$@"
}

koopa::data_disk_link_prefix() {
    _koopa_data_disk_link_prefix "$@"
}

koopa::deactivate_conda() {
    _koopa_deactivate_conda "$@"
}

koopa::deactivate_envs() {
    _koopa_deactivate_envs "$@"
}

koopa::deactivate_venv() {
    _koopa_deactivate_venv "$@"
}

koopa::dl() {
    _koopa_dl "$@"
}

koopa::docker_prefix() {
    _koopa_docker_prefix "$@"
}

koopa::docker_private_prefix() {
    _koopa_docker_private_prefix "$@"
}

koopa::dotfiles_prefix() {
    _koopa_dotfiles_prefix "$@"
}

koopa::dotfiles_private_prefix() {
    _koopa_dotfiles_private_prefix "$@"
}

koopa::emacs_prefix() {
    _koopa_emacs_prefix "$@"
}

koopa::ensembl_perl_api_prefix() {
    _koopa_ensembl_perl_api_prefix "$@"
}

koopa::expr() {
    _koopa_expr "$@"
}

koopa::force_add_to_manpath_end() {
    _koopa_force_add_to_manpath_end "$@"
}

koopa::force_add_to_manpath_start() {
    _koopa_force_add_to_manpath_start "$@"
}

koopa::force_add_to_path_end() {
    _koopa_force_add_to_path_end "$@"
}

koopa::force_add_to_path_start() {
    _koopa_force_add_to_path_start "$@"
}

koopa::force_add_to_pkg_config_path_end() {
    _koopa_force_add_to_pkg_config_path_end "$@"
}

koopa::force_add_to_pkg_config_path_start() {
    _koopa_force_add_to_pkg_config_path_start "$@"
}

koopa::fzf_prefix() {
    _koopa_fzf_prefix "$@"
}

koopa::git_branch() {
    _koopa_git_branch "$@"
}

koopa::go_gopath() {
    _koopa_go_gopath "$@"
}

koopa::group() {
    _koopa_group "$@"
}

koopa::group_id() {
    _koopa_group_id "$@"
}

koopa::gsub() {
    _koopa_gsub "$@"
}

koopa::has_gnu() {
    _koopa_has_gnu "$@"
}

koopa::has_gnu_binutils() {
    _koopa_has_gnu_binutils "$@"
}

koopa::has_gnu_coreutils() {
    _koopa_has_gnu_coreutils "$@"
}

koopa::has_gnu_findutils() {
    _koopa_has_gnu_findutils "$@"
}

koopa::has_gnu_sed() {
    _koopa_has_gnu_sed "$@"
}

koopa::has_gnu_tar() {
    _koopa_has_gnu_tar "$@"
}

koopa::h1() {
    _koopa_h1 "$@"
}

koopa::h2() {
    _koopa_h2 "$@"
}

koopa::h3() {
    _koopa_h3 "$@"
}

koopa::h4() {
    _koopa_h4 "$@"
}

koopa::h5() {
    _koopa_h5 "$@"
}

koopa::h6() {
    _koopa_h6 "$@"
}

koopa::h7() {
    _koopa_h7 "$@"
}

koopa::homebrew_cellar_prefix() {
    _koopa_homebrew_cellar_prefix "$@"
}

koopa::homebrew_prefix() {
    _koopa_homebrew_prefix "$@"
}

koopa::homebrew_ruby_gems_prefix() {
    _koopa_homebrew_ruby_gems_prefix "$@"
}

koopa::hostname() {
    _koopa_hostname "$@"
}

koopa::host_id() {
    _koopa_host_id "$@"
}

koopa::include_prefix() {
    _koopa_include_prefix "$@"
}

koopa::info() {
    _koopa_info "$@"
}

koopa::invalid_arg() {
    _koopa_invalid_arg "$@"
}

koopa::is_alias() {
    _koopa_is_alias "$@"
}

koopa::is_alpine() {
    _koopa_is_alpine "$@"
}

koopa::is_amzn() {
    _koopa_is_amzn "$@"
}

koopa::is_arch() {
    _koopa_is_arch "$@"
}

koopa::is_aws() {
    _koopa_is_aws "$@"
}

koopa::is_azure() {
    _koopa_is_azure "$@"
}

koopa::is_centos() {
    _koopa_is_centos "$@"
}

koopa::is_conda_active() {
    _koopa_is_conda_active "$@"
}

koopa::is_debian() {
    _koopa_is_debian "$@"
}

koopa::is_fedora() {
    _koopa_is_fedora "$@"
}

koopa::is_git() {
    _koopa_is_git "$@"
}

koopa::is_git_clean() {
    _koopa_is_git_clean "$@"
}

koopa::is_git_toplevel() {
    _koopa_is_git_toplevel "$@"
}

koopa::is_installed() {
    _koopa_is_installed "$@"
}

koopa::is_interactive() {
    _koopa_is_installed "$@"
}

koopa::is_linux() {
    _koopa_is_linux "$@"
}

koopa::is_local_install() {
    _koopa_is_local_install "$@"
}

koopa::is_macos() {
    _koopa_is_macos "$@"
}

koopa::is_opensuse() {
    _koopa_is_opensuse "$@"
}

koopa::is_raspbian() {
    _koopa_is_raspbian "$@"
}

koopa::is_remote() {
    _koopa_is_remote "$@"
}

koopa::is_rhel() {
    _koopa_is_rhel "$@"
}

koopa::is_rhel_7() {
    _koopa_is_rhel_7 "$@"
}

koopa::is_rhel_8() {
    _koopa_is_rhel_8 "$@"
}

koopa::is_root() {
    _koopa_is_root "$@"
}

koopa::is_rstudio() {
    _koopa_is_rstudio "$@"
}

koopa::is_set_nounset() {
    _koopa_is_set_nounset "$@"
}

koopa::is_shared_install() {
    _koopa_is_shared_install "$@"
}

koopa::is_subshell() {
    _koopa_is_subshell "$@"
}

koopa::kebab_case() {
    _koopa_kebab_case "$@"
}

koopa::lowercase() {
    _koopa_lowercase "$@"
}

koopa::is_tmux() {
    _koopa_is_tmux "$@"
}

koopa::is_tty() {
    _koopa_is_tty "$@"
}

koopa::is_ubuntu() {
    _koopa_is_ubuntu "$@"
}

koopa::is_ubuntu_18() {
    _koopa_is_ubuntu_18 "$@"
}

koopa::is_ubuntu_20() {
    _koopa_is_ubuntu_18 "$@"
}

koopa::is_venv_active() {
    _koopa_is_ubuntu_18 "$@"
}

koopa::java_prefix() {
    _koopa_java_prefix "$@"
}

koopa::local_app_prefix() {
    _koopa_local_app_prefix "$@"
}

koopa::macos_version() {
    _koopa_macos_version "$@"
}

koopa::major_version() {
    _koopa_major_version "$@"
}

koopa::major_minor_version() {
    _koopa_major_minor_version "$@"
}

koopa::major_minor_patch_version() {
    _koopa_major_minor_patch_version "$@"
}

koopa::make_prefix() {
    _koopa_make_prefix "$@"
}

koopa::missing_arg() {
    _koopa_missing_arg "$@"
}

koopa::msigdb_prefix() {
    _koopa_msigdb_prefix "$@"
}

koopa::monorepo_prefix() {
    _koopa_monorepo_prefix "$@"
}

koopa::note() {
    _koopa_note "$@"
}

koopa::openjdk_prefix() {
    _koopa_openjdk_prefix "$@"
}

koopa::os_codename() {
    _koopa_os_codename "$@"
}

koopa::os_id() {
    _koopa_os_id "$@"
}

koopa::os_string() {
    _koopa_os_string "$@"
}

koopa::parent_dir() {
    _koopa_parent_dir "$@"
}

koopa::perlbrew_prefix() {
    _koopa_perlbrew_prefix "$@"
}

koopa::prefix() {
    _koopa_prefix "$@"
}

koopa::prompt() {
    _koopa_prompt "$@"
}

koopa::print() {
    _koopa_print "$@"
}

koopa::print_black() {
    _koopa_print_black "$@"
}

koopa::print_black_bold() {
    _koopa_print_black_bold "$@"
}

koopa::print_blue() {
    _koopa_print_blue "$@"
}

koopa::print_blue_bold() {
    _koopa_print_blue_bold "$@"
}

koopa::print_cyan() {
    _koopa_print_cyan "$@"
}

koopa::print_cyan_bold() {
    _koopa_print_cyan_bold "$@"
}

koopa::print_default() {
    _koopa_print_default "$@"
}

koopa::print_default_bold() {
    _koopa_print_default_bold "$@"
}

koopa::print_green() {
    _koopa_print_green "$@"
}

koopa::print_green_bold() {
    _koopa_print_green_bold "$@"
}

koopa::print_magenta() {
    _koopa_print_magenta "$@"
}

koopa::print_magenta_bold() {
    _koopa_print_magenta_bold "$@"
}

koopa::print_red() {
    _koopa_print_red "$@"
}

koopa::print_red_bold() {
    _koopa_print_red_bold "$@"
}

koopa::print_yellow() {
    _koopa_print_yellow "$@"
}

koopa::print_yellow_bold() {
    _koopa_print_yellow_bold "$@"
}

koopa::print_white() {
    _koopa_print_white "$@"
}

koopa::print_white_bold() {
    _koopa_print_white_bold "$@"
}

koopa::pyenv_prefix() {
    _koopa_pyenv_prefix "$@"
}

koopa::python_site_packages_prefix() {
    _koopa_python_site_packages_prefix "$@"
}

koopa::rbenv_prefix() {
    _koopa_rbenv_prefix "$@"
}

koopa::realpath() {
    _koopa_realpath "$@"
}

koopa::refdata_prefix() {
    _koopa_refdata_prefix "$@"
}

koopa::remove_from_manpath() {
    _koopa_remove_from_manpath "$@"
}

koopa::remove_from_path() {
    _koopa_remove_from_path "$@"
}

koopa::ruby_api_version() {
    _koopa_ruby_api_version "$@"
}

koopa::rust_cargo_prefix() {
    _koopa_rust_cargo_prefix "$@"
}

koopa::rust_rustup_prefix() {
    _koopa_rust_rustup_prefix "$@"
}

koopa::scripts_private_prefix() {
    _koopa_scripts_private_prefix "$@"
}

koopa::shell() {
    _koopa_shell "$@"
}

koopa::snake_case() {
    _koopa_snake_case "$@"
}

koopa::stop() {
    _koopa_stop "$@"
}

koopa::str_match() {
    _koopa_str_match "$@"
}

koopa::str_match_posix() {
    _koopa_str_match_posix "$@"
}

koopa::str_match_regex() {
    _koopa_str_match_regex "$@"
}

koopa::strip_left() {
    _koopa_strip_left "$@"
}

koopa::strip_right() {
    _koopa_strip_right "$@"
}

koopa::strip_trailing_slash() {
    _koopa_strip_trailing_slash "$@"
}

koopa::sub() {
    _koopa_sub "$@"
}

koopa::success() {
    _koopa_success "$@"
}

koopa::tests_prefix() {
    _koopa_tests_prefix "$@"
}

koopa::trim_ws() {
    _koopa_trim_ws "$@"
}

koopa::user() {
    _koopa_user "$@"
}

koopa::user_id() {
    _koopa_user_id "$@"
}

koopa::variable() {
    _koopa_variable "$@"
}

koopa::venv() {
    _koopa_venv "$@"
}

koopa::venv_prefix() {
    _koopa_venv_prefix "$@"
}

koopa::warning() {
    _koopa_warning "$@"
}

koopa::which() {
    _koopa_which "$@"
}

koopa::which_realpath() {
    _koopa_which_realpath "$@"
}

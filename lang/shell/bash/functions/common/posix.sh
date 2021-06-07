#!/usr/bin/env bash

koopa:::ansi_escape() { # {{{1
    __koopa_ansi_escape "$@"
}

koopa:::msg() { # {{{1
    __koopa_msg "$@"
}

koopa::activate_aspera() { # {{{1
    _koopa_activate_aspera "$@"
}

koopa::activate_bcbio() { # {{{1
    _koopa_activate_bcbio "$@"
}

koopa::activate_conda() { # {{{1
    _koopa_activate_conda "$@"
}

koopa::activate_emacs() { # {{{1
    _koopa_activate_emacs "$@"
}

koopa::activate_fzf() { # {{{1
    _koopa_activate_fzf "$@"
}

koopa::activate_go() { # {{{1
    _koopa_activate_go "$@"
}

koopa::activate_homebrew() { # {{{1
    _koopa_activate_homebrew "$@"
}

koopa::activate_homebrew_cask_google_cloud_sdk() { # {{{1
    _koopa_activate_homebrew_cask_google_cloud_sdk "$@"
}

koopa::activate_homebrew_cask_gpg_suite() { # {{{1
    _koopa_activate_homebrew_cask_gpg_suite "$@"
}

koopa::activate_homebrew_cask_julia() { # {{{1
    _koopa_activate_homebrew_cask_julia "$@"
}

koopa::activate_homebrew_cask_r() { # {{{1
    _koopa_activate_homebrew_cask_r "$@"
}

koopa::activate_homebrew_opt_gnu_prefix() { # {{{1
    _koopa_activate_homebrew_opt_gnu_prefix "$@"
}

koopa::activate_homebrew_opt_prefix() { # {{{1
    _koopa_activate_homebrew_opt_prefix "$@"
}

koopa::activate_koopa_paths() { # {{{1
    _koopa_activate_koopa_paths "$@"
}

koopa::activate_llvm() { # {{{1
    _koopa_activate_llvm "$@"
}

koopa::activate_local_etc_profile() { # {{{1
    _koopa_activate_local_etc_profile "$@"
}

koopa::activate_local_paths() { # {{{1
    _koopa_activate_local_paths "$@"
}

koopa::activate_nextflow() { # {{{1
    _koopa_activate_nextflow "$@"
}

koopa::activate_node() { # {{{1
    _koopa_activate_node "$@"
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

koopa::activate_perlbrew() { # {{{1
    _koopa_activate_perlbrew "$@"
}

koopa::activate_pipx() { # {{{1
    _koopa_activate_pipx "$@"
}

koopa::activate_pkg_config() { # {{{1
    _koopa_activate_pkg_config "$@"
}

koopa::activate_prefix() { # {{{1
    _koopa_activate_prefix "$@"
}

koopa::activate_pyenv() { # {{{1
    _koopa_activate_pyenv "$@"
}

koopa::activate_python_packages() { # {{{1
    _koopa_activate_python_packages "$@"
}

koopa::activate_python_startup() { # {{{1
    _koopa_activate_python_startup "$@"
}

koopa::activate_rbenv() { # {{{1
    _koopa_activate_rbenv "$@"
}

koopa::activate_ruby() { # {{{1
    _koopa_activate_ruby "$@"
}

koopa::activate_rust() { # {{{1
    _koopa_activate_rust "$@"
}

koopa::activate_secrets() { # {{{1
    _koopa_activate_secrets "$@"
}

koopa::activate_ssh_key() { # {{{1
    _koopa_activate_ssh_key "$@"
}

koopa::activate_standard_paths() { # {{{1
    _koopa_activate_standard_paths "$@"
}

koopa::activate_venv() { # {{{1
    _koopa_activate_venv "$@"
}

koopa::activate_xdg() { # {{{1
    _koopa_activate_xdg "$@"
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

koopa::alert_info() { # {{{1
    _koopa_alert_info "$@"
}

koopa::alert_is_installed() { # {{{1
    _koopa_alert_is_installed "$@"
}

koopa::alert_is_not_installed() { # {{{1
    _koopa_alert_is_not_installed "$@"
}

koopa::alert_note() { # {{{1
    _koopa_alert_note "$@"
}

koopa::alert_success() { # {{{1
    _koopa_alert_success "$@"
}

koopa::anaconda_prefix() { # {{{1
    _koopa_anaconda_prefix "$@"
}

koopa::app_prefix() { # {{{1
    _koopa_app_prefix "$@"
}

koopa::arch() { # {{{1
    _koopa_arch "$@"
}

koopa::arch2() { # {{{1
    _koopa_arch2 "$@"
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

koopa::check_os() { # {{{1
    _koopa_check_os "$@"
}

koopa::check_shell() { # {{{1
    _koopa_check_shell "$@"
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

koopa::doom_emacs_prefix() { # {{{1
    _koopa_doom_emacs_prefix "$@"
}

koopa::dotfiles_prefix() { # {{{1
    _koopa_dotfiles_prefix "$@"
}

koopa::dotfiles_private_prefix() { # {{{1
    _koopa_dotfiles_private_prefix "$@"
}

koopa::duration_start() { # {{{1
    _koopa_duration_start "$@"
}

koopa::duration_stop() { # {{{1
    _koopa_duration_stop "$@"
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

koopa::export_cpu_count() { # {{{1
    _koopa_export_cpu_count "$@"
}

koopa::export_editor() { # {{{1
    _koopa_export_editor "$@"
}

koopa::export_gnupg() { # {{{1
    _koopa_export_gnupg "$@"
}

koopa::export_git() { # {{{1
    _koopa_export_git "$@"
}

koopa::export_history() { # {{{1
    _koopa_export_history "$@"
}

koopa::export_pager() { # {{{1
    _koopa_export_pager "$@"
}

koopa::export_python() { # {{{1
    _koopa_export_python "$@"
}

koopa::export_shell() { # {{{1
    _koopa_export_shell "$@"
}

koopa::export_user() { # {{{1
    _koopa_export_user "$@"
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

koopa::go_packages_prefix() { # {{{1
    _koopa_go_packages_prefix "$@"
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

koopa::is_docker() { # {{{1
    _koopa_is_docker "$@"
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

koopa::is_gnu() { # {{{1
    _koopa_is_gnu "$@"
}

koopa::is_host() { # {{{1
    _koopa_is_host "$@"
}

koopa::is_installed() { # {{{1
    _koopa_is_installed "$@"
}

koopa::is_interactive() { # {{{1
    _koopa_is_interactive "$@"
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

koopa::is_qemu() { # {{{1
    _koopa_is_qemu "$@"
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

koopa::koopa_prefix() { # {{{1
    _koopa_koopa_prefix "$@"
}

koopa::lmod_prefix() { # {{{1
    _koopa_lmod_prefix "$@"
}

koopa::local_data_prefix() { # {{{1
    _koopa_local_data_prefix "$@"
}

koopa::locate_shell() { # {{{1
    _koopa_locate_shell "$@"
}

koopa::lowercase() { # {{{1
    _koopa_lowercase "$@"
}

koopa::macos_activate_python() { # {{{1
    _koopa_macos_activate_python "$@"
}

koopa::macos_activate_visual_studio_code() { # {{{1
    _koopa_macos_activate_visual_studio_code "$@"
}

koopa::macos_is_dark_mode() { # {{{1
    _koopa_macos_is_dark_mode "$@"
}

koopa::macos_is_light_mode() { # {{{1
    _koopa_macos_is_light_mode "$@"
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

koopa::msigdb_prefix() { # {{{1
    _koopa_msigdb_prefix "$@"
}

koopa::monorepo_prefix() { # {{{1
    _koopa_monorepo_prefix "$@"
}

koopa::ngettext() { # {{{1
    _koopa_ngettext "$@"
}

koopa::node_packages_prefix() { # {{{1
    _koopa_node_packages_prefix "$@"
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

koopa::perl_packages_prefix() { # {{{1
    _koopa_perl_packages_prefix "$@"
}

koopa::perlbrew_prefix() { # {{{1
    _koopa_perlbrew_prefix "$@"
}

koopa::pipx_prefix() { # {{{1
    _koopa_pipx_prefix "$@"
}

koopa::prelude_emacs_prefix() { # {{{1
    _koopa_prelude_emacs_prefix "$@"
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

koopa::python_packages_prefix() { # {{{1
    _koopa_python_packages_prefix "$@"
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

koopa::ruby_packages_prefix() { # {{{1
    _koopa_ruby_packages_prefix "$@"
}

koopa::rust_packages_prefix() { # {{{1
    _koopa_rust_packages_prefix "$@"
}

koopa::rust_prefix() { # {{{1
    _koopa_rust_prefix "$@"
}

koopa::scripts_private_prefix() { # {{{1
    _koopa_scripts_private_prefix "$@"
}

koopa::shell_name() { # {{{1
    _koopa_shell_name "$@"
}

koopa::snake_case_simple() { # {{{1
    _koopa_snake_case_simple "$@"
}

koopa::source_dir() { # {{{1
    _koopa_source_dir "$@"
}

koopa::spacemacs_prefix() { # {{{1
    _koopa_spacemacs_prefix "$@"
}

koopa::spacevim_prefix() { # {{{1
    _koopa_spacevim_prefix "$@"
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

koopa::umask() { # {{{1
    _koopa_umask "$@"
}

koopa::user() { # {{{1
    _koopa_user "$@"
}

koopa::user_id() { # {{{1
    _koopa_user_id "$@"
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

koopa::xdg_cache_home() { # {{{1
    _koopa_xdg_cache_home "$@"
}

koopa::xdg_config_dirs() { # {{{1
    _koopa_xdg_config_dirs "$@"
}

koopa::xdg_config_home() { # {{{1
    _koopa_xdg_config_home "$@"
}

koopa::xdg_data_dirs() { # {{{1
    _koopa_xdg_data_dirs "$@"
}

koopa::xdg_data_home() { # {{{1
    _koopa_xdg_data_home "$@"
}

koopa::xdg_local_home() { # {{{1
    _koopa_xdg_local_home "$@"
}

koopa::xdg_runtime_dir() { # {{{1
    _koopa_xdg_runtime_dir "$@"
}

#!/usr/bin/env bash

koopa:::ansi_escape() { # {{{1
    __koopa_ansi_escape "$@"
}

koopa:::msg() { # {{{1
    __koopa_msg "$@"
}

koopa::activate_anaconda() { # {{{1
    _koopa_activate_anaconda "$@"
}

koopa::activate_aspera_connect() { # {{{1
    _koopa_activate_aspera_connect "$@"
}

koopa::activate_bcbio_nextgen() { # {{{1
    _koopa_activate_bcbio_nextgen "$@"
}

koopa::activate_conda() { # {{{1
    _koopa_activate_conda "$@"
}

koopa::activate_doom_emacs() { # {{{1
    _koopa_activate_doom_emacs "$@"
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

koopa::activate_homebrew_opt_gnu_prefix() { # {{{1
    _koopa_activate_homebrew_opt_gnu_prefix "$@"
}

koopa::activate_homebrew_opt_prefix() { # {{{1
    _koopa_activate_homebrew_opt_prefix "$@"
}

koopa::activate_julia() { # {{{1
    _koopa_activate_julia "$@"
}

koopa::activate_koopa_paths() { # {{{1
    _koopa_activate_koopa_paths "$@"
}

koopa::activate_local_paths() { # {{{1
    _koopa_activate_local_paths "$@"
}

koopa::activate_make_paths() { # {{{1
    _koopa_activate_make_paths "$@"
}

koopa::activate_nextflow() { # {{{1
    _koopa_activate_nextflow "$@"
}

koopa::activate_nim() { # {{{1
    _koopa_activate_nim "$@"
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

koopa::activate_perl() { # {{{1
    _koopa_activate_perl "$@"
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

koopa::activate_python() { # {{{1
    _koopa_activate_python "$@"
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

koopa::activate_xdg() { # {{{1
    _koopa_activate_xdg "$@"
}

koopa::add_koopa_config_link() { # {{{1
    _koopa_add_koopa_config_link "$@"
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

koopa::add_to_pkg_config_path_end_2() { # {{{1
    _koopa_add_to_pkg_config_path_end_2 "$@"
}

koopa::add_to_pkg_config_path_start() { # {{{1
    _koopa_add_to_pkg_config_path_start "$@"
}

koopa::add_to_pkg_config_path_start_2() { # {{{1
    _koopa_add_to_pkg_config_path_start_2 "$@"
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

koopa::aspera_connect_prefix() { # {{{1
    _koopa_aspera_connect_prefix "$@"
}

koopa::bcbio_nextgen_tools_prefix() { # {{{1
    _koopa_bcbio_nextgen_tools_prefix "$@"
}

koopa::boolean_nounset() { # {{{1
    _koopa_boolean_nounset "$@"
}

koopa::conda_env_name() { # {{{1
    _koopa_conda_env_name "$@"
}

koopa::conda_prefix() { # {{{1
    _koopa_conda_prefix "$@"
}

koopa::config_prefix() { # {{{1
    _koopa_config_prefix "$@"
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

koopa::export_koopa_shell() { # {{{1
    _koopa_export_koopa_shell "$@"
}

koopa::export_pager() { # {{{1
    _koopa_export_pager "$@"
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

koopa::git_repo_has_unstaged_changes() { # {{{1
    _koopa_git_repo_has_unstaged_changes "$@"
}

koopa::git_repo_needs_pull_or_push() { # {{{1
    _koopa_git_repo_needs_pull_or_push "$@"
}

# FIXME Require user to pass in '--version' here, it makes it less confusing.
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

koopa::homebrew_cellar_prefix() { # {{{1
    _koopa_homebrew_cellar_prefix "$@"
}

koopa::homebrew_prefix() { # {{{1
    _koopa_homebrew_prefix "$@"
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

koopa::is_aarch64() { # {{{1
    _koopa_is_aarch64 "$@"
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

koopa::is_conda_env_active() { # {{{1
    _koopa_is_conda_env_active "$@"
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

koopa::is_git_repo() { # {{{1
    _koopa_is_git_repo "$@"
}

koopa::is_git_repo_clean() { # {{{1
    _koopa_is_git_repo_clean "$@"
}

koopa::is_git_repo_top_level() { # {{{1
    _koopa_is_git_repo_top_level "$@"
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

koopa::is_python_venv_active() { # {{{1
    _koopa_is_python_venv_active "$@"
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

koopa::is_rocky() { # {{{1
    _koopa_is_rocky "$@"
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

koopa::is_x86_64() { # {{{1
    _koopa_is_x86_64 "$@"
}

koopa::java_prefix() { # {{{1
    _koopa_java_prefix "$@"
}

# FIXME Require user to pass in '--version' here, it makes it less confusing.
koopa::julia_packages_prefix() { # {{{1
    _koopa_julia_packages_prefix "$@"
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

koopa::macos_activate_google_cloud_sdk() { # {{{1
    _koopa_macos_activate_google_cloud_sdk "$@"
}

koopa::macos_activate_gpg_suite() { # {{{1
    _koopa_macos_activate_gpg_suite "$@"
}

koopa::macos_activate_r() { # {{{1
    _koopa_macos_activate_r "$@"
}

koopa::macos_activate_visual_studio_code() { # {{{1
    _koopa_macos_activate_visual_studio_code "$@"
}

koopa::macos_gfortran_prefix() { # {{{1
    _koopa_macos_gfortran_prefix "$@"
}

koopa::macos_is_dark_mode() { # {{{1
    _koopa_macos_is_dark_mode "$@"
}

koopa::macos_is_light_mode() { # {{{1
    _koopa_macos_is_light_mode "$@"
}

koopa::macos_julia_prefix() { # {{{1
    _koopa_macos_julia_prefix "$@"
}

koopa::macos_python_prefix() { # {{{1
    _koopa_macos_python_prefix "$@"
}

koopa::macos_r_prefix() { # {{{1
    _koopa_macos_r_prefix "$@"
}

koopa::macos_os_version() { # {{{1
    _koopa_macos_os_version "$@"
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

koopa::msigdb_prefix() { # {{{1
    _koopa_msigdb_prefix "$@"
}

koopa::monorepo_prefix() { # {{{1
    _koopa_monorepo_prefix "$@"
}

# FIXME Require user to pass in '--version' here, it makes it less confusing.
koopa::nim_packages_prefix() { # {{{1
    _koopa_nim_packages_prefix "$@"
}

# FIXME Require user to pass in '--version' here, it makes it less confusing.
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

# FIXME Require user to pass in '--version' here, it makes it less confusing.
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

# FIXME Require user to pass in '--version' here, it makes it less confusing.
koopa::python_packages_prefix() { # {{{1
    _koopa_python_packages_prefix "$@"
}

koopa::python_venv_name() { # {{{1
    _koopa_python_venv_name "$@"
}

koopa::python_venv_prefix() { # {{{1
    _koopa_python_venv_prefix "$@"
}

# FIXME Require user to pass in '--version' here, it makes it less confusing.
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

# FIXME Require user to pass in '--version' here, it makes it less confusing.
koopa::ruby_packages_prefix() { # {{{1
    _koopa_ruby_packages_prefix "$@"
}

# FIXME Require user to pass in '--version' here, it makes it less confusing.
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

koopa::spacemacs_prefix() { # {{{1
    _koopa_spacemacs_prefix "$@"
}

koopa::spacevim_prefix() { # {{{1
    _koopa_spacevim_prefix "$@"
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

koopa::today() { # {{{1
    _koopa_today "$@"
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

koopa::warn() { # {{{1
    _koopa_warn "$@"
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

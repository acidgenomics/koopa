# Functions                                                                 {{{1
# ==============================================================================

# bash: `declare -F`.

unset -f usage
unset -f \
    add_koopa_bins_to_path \
    add_local_bins_to_path \
    add_to_path_end \
    add_to_path_start \
    assert_has_no_environments \
    assert_has_sudo \
    assert_is_installed \
    assert_is_not_dir \
    assert_is_os_darwin \
    assert_is_os_debian \
    assert_is_os_fedora \
    build_chgrp \
    build_mkdir \
    build_prefix \
    build_prefix_group \
    build_set_permissions \
    delete_dotfile \
    find_local_bin_dirs \
    force_add_to_path_end \
    force_add_to_path_start \
    has_sudo \
    koopa_variable \
    link_cellar \
    quiet_cd \
    quiet_expr \
    quiet_which \
    remove_from_path \
    update_ldconfig \
    update_profile \
    update_r_config \
    update_xdg_config

# dequote
# quote
# quote_readline



# Variables                                                                 {{{1
# ==============================================================================

# bash:
# - all: `declare -p`
# - exported: `declare -px`

# colors
# dir
# dirs

unset -v activate_dir
unset -v \
    aspera \
    bcbio \
    conda \
    debug \
    help \
    homebrew \
    minimal \
    perlbrew \
    prompt \
    rbenv \
    ssh_key \
    virtualenv
unset -v colors

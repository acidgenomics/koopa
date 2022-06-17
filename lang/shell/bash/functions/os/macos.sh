#!/bin/sh
# shellcheck disable=all

koopa_macos_app_version() {
    local app x
    koopa_assert_has_args "$#"
    declare -A app=(
        [awk]="$(koopa_locate_awk)"
        [plutil]="$(koopa_macos_locate_plutil)"
        [tr]="$(koopa_locate_tr)"
    )
    [[ -x "${app[awk]}" ]] || return 1
    [[ -x "${app[plutil]}" ]] || return 1
    [[ -x "${app[tr]}" ]] || return 1
    for app in "$@"
    do
        plist="/Applications/${app}.app/Contents/Info.plist"
        [[ -f "$plist" ]] || return 1
        x="$( \
            "${app[plutil]}" -p "$plist" \
                | koopa_grep --pattern='CFBundleShortVersionString' - \
                | "${app[awk]}" -F ' => ' '{print $2}' \
                | "${app[tr]}" --delete '\"' \
        )"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_macos_brew_cask_outdated() {
    local app keep_latest tmp_file x
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
        [cut]="$(koopa_locate_cut)"
    )
    keep_latest=0
    tmp_file="$(koopa_tmp_file)"
    script -q "$tmp_file" \
        "${app[brew]}" outdated --cask --greedy >/dev/null
    if [[ "$keep_latest" -eq 1 ]]
    then
        x="$("${app[cut]}" -d ' ' -f '1' < "$tmp_file")"
    else
        x="$( \
            koopa_grep \
                --file="$tmp_file" \
                --invert-match \
                --pattern='(latest)' \
            | "${app[cut]}" -d ' ' -f '1' \
        )"
    fi
    koopa_rm "$tmp_file"
    [[ -n "$x" ]] || return 0
    koopa_print "$x"
    return 0
}

koopa_macos_brew_cask_quarantine_fix() {
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [xattr]="$(koopa_macos_locate_xattr)"
    )
    "${app[sudo]}" "${app[xattr]}" -r -d \
        'com.apple.quarantine' \
        '/Applications/'*'.app'
    return 0
}

koopa_macos_brew_upgrade_casks() {
    local app cask casks
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    readarray -t casks <<< "$(koopa_macos_brew_cask_outdated)"
    koopa_is_array_non_empty "${casks[@]:-}" || return 0
    koopa_dl \
        "$(koopa_ngettext \
            --num="${#casks[@]}" \
            --msg1='outdated cask' \
            --msg2='outdated casks' \
        )" \
        "$(koopa_to_string "${casks[@]}")"
    for cask in "${casks[@]}"
    do
        case "$cask" in
            'docker')
                cask='homebrew/cask/docker'
                ;;
            'macvim')
                cask='homebrew/cask/macvim'
                ;;
        esac
        "${app[brew]}" reinstall --cask --force "$cask" || true
        case "$cask" in
            'adoptopenjdk' | \
            'openjdk' | \
            'r' | \
            'temurin')
                app[r]="$(koopa_macos_r_prefix)/bin/R"
                koopa_configure_r "${app[r]}"
                ;;
            'google-'*)
                koopa_macos_disable_google_keystone || true
                ;;
            'gpg-suite'*)
                koopa_macos_disable_gpg_updater
                ;;
            'macvim')
                "${app[brew]}" unlink 'vim'
                "${app[brew]}" link 'vim'
                ;;
            'microsoft-teams')
                koopa_macos_disable_microsoft_teams_updater
                ;;
        esac
    done
    return 0
}

koopa_macos_clean_launch_services() {
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [kill_all]="$(koopa_macos_locate_kill_all)"
        [lsregister]="$(koopa_macos_locate_lsregister)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_alert "Cleaning LaunchServices 'Open With' menu."
    "${app[lsregister]}" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    "${app[sudo]}" "${app[kill_all]}" 'Finder'
    koopa_alert_success 'Clean up was successful.'
    return 0
}

koopa_macos_create_dmg() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [hdiutil]="$(koopa_macos_locate_hdiutil)"
    )
    declare -A dict=(
        [srcfolder]="${1:?}"
    )
    koopa_assert_is_dir "${dict[srcfolder]}"
    dict[srcfolder]="$(koopa_realpath "${dict[srcfolder]}")"
    dict[volname]="$(koopa_basename "${dict[volname]}")"
    dict[ov]="${dict[volname]}.dmg"
    "${app[hdiutil]}" create \
        -ov "${dict[ov]}" \
        -srcfolder "${dict[srcfolder]}" \
        -volname "${dict[volname]}"
    return 0
}

koopa_macos_disable_crashplan() {
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        "${HOME:?}/Library/LaunchAgents/com.crashplan.engine.plist" \
        '/Library/LaunchDaemons/com.crashplan.engine.plist'
    return 0
}

koopa_macos_disable_google_keystone() {
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchAgents/com.google.keystone.agent.plist' \
        '/Library/LaunchAgents/com.google.keystone.xpcservice.plist' \
        '/Library/LaunchDaemons/com.google.keystone.daemon.plist'
    return 0
}

koopa_macos_disable_gpg_updater() {
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}

koopa_macos_disable_microsoft_teams_updater() { # {[[1
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchDaemons/com.microsoft.teams.TeamsUpdaterDaemon.plist'
    return 0
}

koopa_macos_disable_plist_file() {
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [launchctl]="$(koopa_macos_locate_launchctl)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_assert_is_file "$@"
    for file in "$@"
    do
        local dict
        declare -A dict=(
            [daemon]=0
            [enabled_file]="$file"
            [sudo]=1
        )
        dict[disabled_file]="$(koopa_dirname "${dict[enabled_file]}")/\
disabled/$(koopa_basename "${dict[enabled_file]}")"
        koopa_alert "Disabling '${dict[enabled_file]}'."
        if koopa_str_detect_fixed \
            --string="${dict[enabled_file]}" \
            --pattern='/LaunchDaemons/'
        then
            dict[daemon]=1
        fi
        if koopa_str_detect_regex \
            --string="${dict[enabled_file]}" \
            --pattern="^${HOME:?}"
        then
            dict[sudo]=0
        fi
        case "${dict[sudo]}" in
            '0')
                if [[ "${dict[daemon]}" -eq 1 ]]
                then
                    "${app[launchctl]}" \
                        unload "${dict[enabled_file]}"
                fi
                koopa_mv \
                    "${dict[enabled_file]}" \
                    "${dict[disabled_file]}"
                ;;
            '1')
                if [[ "${dict[daemon]}" -eq 1 ]]
                then
                    "${app[sudo]}" "${app[launchctl]}" \
                        unload "${dict[enabled_file]}"
                fi
                koopa_mv --sudo \
                    "${dict[enabled_file]}" \
                    "${dict[disabled_file]}"
                ;;
        esac
    done
    return 0
}

koopa_macos_disable_privileged_helper_tool() {
    local bn dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    for bn in "$@"
    do
        local dict
        declare -A dict=(
            [enabled_file]="/Library/PrivilegedHelperTools/${bn}"
        )
        dict[disabled_file]="$(koopa_dirname "${dict[enabled_file]}")/\
disabled/$(koopa_basename "${dict[enabled_file]}")"
        koopa_assert_is_file "${dict[enabled_file]}"
        koopa_assert_is_not_file "${dict[disabled_file]}"
        koopa_alert "Disabling '${dict[disabled_file]}'."
        koopa_mv --sudo "${dict[enabled_file]}" "${dict[disabled_file]}"
    done
    return 0
}

koopa_macos_disable_spotlight_indexing() {
    local app
    declare -A app=(
        [mdutil]="$(koopa_macos_locate_mdutil)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[mdutil]}" ]] || return 1
    [[ -x "${app[sudo]}" ]] || return 1
    "${app[sudo]}" "${app[mdutil]}" -a -i off
    "${app[mdutil]}" -a -s
    return 0
}

koopa_macos_disable_touch_id_sudo() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [cp]="$(koopa_locate_cp)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [source_file]="$(koopa_koopa_prefix)/os/macos/etc/pam.d/sudo~orig"
        [target_file]='/etc/pam.d/sudo'
    )
    if [[ -f "${dict[target_file]}" ]] && \
        ! koopa_file_detect_fixed \
            --file="${dict[target_file]}" \
            --pattern='pam_tid.so'
    then
        koopa_alert_note "Touch ID not enabled in '${dict[target_file]}'."
        return 0
    fi
    koopa_alert "Disabling Touch ID defined in '${dict[target_file]}'."
    "${app[sudo]}" "${app[cp]}" -v \
        "${dict[source_file]}" "${dict[target_file]}"
    koopa_chmod --sudo '0444' "${dict[target_file]}"
    koopa_alert_success 'Touch ID disabled for sudo.'
    return 0
}

koopa_macos_disable_zoom_daemon() {
    koopa_assert_has_no_args "$#"
    koopa_macos_disable_plist_file \
        '/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist'
    koopa_macos_disable_privileged_helper_tool \
        'us.zoom.ZoomDaemon'
}

koopa_macos_download_macos() {
    local app dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [softwareupdate]="$(koopa_macos_locate_softwareupdate)"
    )
    declare -A dict=(
        [version]="${1:?}"
    )
    "${app[softwareupdate]}" \
        --fetch-full-installer \
        --full-installer-version "${dict[version]}"
    return 0
}

koopa_macos_enable_crashplan() {
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        "${HOME:?}/Library/LaunchAgents/com.crashplan.engine.plist" \
        '/Library/LaunchDaemons/com.crashplan.engine.plist'
    return 0
}

koopa_macos_enable_google_keystone() {
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchAgents/com.google.keystone.agent.plist' \
        '/Library/LaunchAgents/com.google.keystone.xpcservice.plist' \
        '/Library/LaunchDaemons/com.google.keystone.daemon.plist'
    return 0
}

koopa_macos_enable_gpg_updater() {
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}

koopa_macos_enable_microsoft_teams_updater() {
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchDaemons/com.microsoft.teams.TeamsUpdaterDaemon.plist'
    return 0
}

koopa_macos_enable_plist_file() {
    local app file
    koopa_assert_has_args "$#"
    declare -A app=(
        [launchctl]="$(koopa_macos_locate_launchctl)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_assert_is_not_file "$@"
    for file in "$@"
    do
        local dict
        declare -A dict=(
            [daemon]=0
            [enabled_file]="$file"
            [sudo]=1
        )
        dict[disabled_file]="$(koopa_dirname "${dict[enabled_file]}")/\
disabled/$(koopa_basename "${dict[enabled_file]}")"
        koopa_alert "Enabling '${dict[enabled_file]}'."
        if koopa_str_detect_fixed \
            --string="${dict[enabled_file]}" \
            --pattern='/LaunchDaemons/'
        then
            dict[daemon]=1
        fi
        if koopa_str_detect_regex \
            --string="${dict[enabled_file]}" \
            --pattern="^${HOME:?}"
        then
            dict[sudo]=0
        fi
        case "${dict[sudo]}" in
            '0')
                koopa_mv \
                    "${dict[disabled_file]}" \
                    "${dict[enabled_file]}"
                if [[ "${dict[daemon]}" -eq 1 ]]
                then
                    "${app[launchctl]}" \
                        load "${dict[enabled_file]}"
                fi
                ;;
            '1')
                koopa_mv --sudo \
                    "${dict[disabled_file]}" \
                    "${dict[enabled_file]}"
                if [[ "${dict[daemon]}" -eq 1 ]]
                then
                    "${app[sudo]}" "${app[launchctl]}" \
                        load "${dict[enabled_file]}"
                fi
                ;;
        esac
    done
    return 0
}

koopa_macos_enable_privileged_helper_tool() {
    local bn dict
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    for bn in "$@"
    do
        local dict
        declare -A dict=(
            [enabled_file]="/Library/PrivilegedHelperTools/${bn}"
        )
        dict[disabled_file]="$(koopa_dirname "${dict[enabled_file]}")/\
disabled/$(koopa_basename "${dict[enabled_file]}")"
        koopa_assert_is_not_file "${dict[enabled_file]}"
        koopa_assert_is_file "${dict[disabled_file]}"
        koopa_alert "Enabling '${dict[disabled_file]}'."
        koopa_mv --sudo "${dict[disabled_file]}" "${dict[enabled_file]}"
    done
    return 0
}

koopa_macos_enable_touch_id_sudo() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [cp]="$(koopa_locate_cp)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [source_file]="$(koopa_koopa_prefix)/os/macos/etc/pam.d/sudo"
        [target_file]='/etc/pam.d/sudo'
    )
    if [[ -f "${dict[target_file]}" ]] && \
        koopa_file_detect_fixed \
            --file="${dict[target_file]}" \
            --pattern='pam_tid.so'
    then
        koopa_alert_note "Touch ID already enabled in '${dict[target_file]}'."
        return 0
    fi
    koopa_alert "Enabling Touch ID in '${dict[target_file]}'."
    koopa_assert_is_file "${dict[source_file]}"
    "${app[sudo]}" "${app[cp]}" -v \
        "${dict[source_file]}" "${dict[target_file]}"
    koopa_chmod --sudo '0444' "${dict[target_file]}"
    koopa_alert_success 'Touch ID enabled for sudo.'
    return 0
}

koopa_macos_enable_zoom_daemon() {
    koopa_assert_has_no_args "$#"
    koopa_macos_enable_plist_file \
        '/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist'
    koopa_macos_enable_privileged_helper_tool \
        'us.zoom.ZoomDaemon'
}

koopa_macos_finder_hide() {
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        [setfile]="$(koopa_macos_locate_setfile)"
    )
    [[ -x "${app[setfile]}" ]] || return 1
    koopa_assert_is_existing "$@"
    "${app[setfile]}" -a V "$@"
    return 0
}

koopa_macos_finder_unhide() {
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        [setfile]="$(koopa_macos_locate_setfile)"
    )
    [[ -x "${app[setfile]}" ]] || return 1
    koopa_assert_is_existing "$@"
    "${app[setfile]}" -a v "$@"
    return 0
}

koopa_macos_flush_dns() {
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [dscacheutil]="$(koopa_macos_locate_dscacheutil)"
        [kill_all]="$(koopa_macos_locate_kill_all)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_alert 'Flushing DNS.'
    "${app[sudo]}" "${app[dscacheutil]}" -flushcache
    "${app[sudo]}" "${app[kill_all]}" -HUP 'mDNSResponder'
    koopa_alert_success 'DNS flush was successful.'
    return 0
}

koopa_macos_force_eject() {
    local app mount name
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [diskutil]="$(koopa_macos_locate_diskutil)"
        [sudo]="$(koopa_locate_sudo)"
    )
    name="${1:?}"
    mount="/Volumes/${name}"
    koopa_assert_is_dir "$mount"
    "${app[sudo]}" "${app[diskutil]}" unmount force "$mount"
    return 0
}

koopa_macos_force_reset_icloud_drive() {
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [kill_all]="$(koopa_macos_locate_kill_all)"
        [reboot]="$(koopa_macos_locate_reboot)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[kill_all]}" bird
    koopa_rm \
        "${HOME:?}/Library/Application Support/CloudDocs" \
        "${HOME:?}/Library/Caches/"*
    "${app[sudo]}" "${app[reboot]}" now
    return 0
}

koopa_macos_homebrew_cask_version() {
    local app cask x
    koopa_assert_has_args "$#"
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
    )
    [[ -x "${app[brew]}" ]] || return 1
    for cask in "$@"
    do
        x="$("${app[brew]}" info --cask "$cask")"
        x="$(koopa_extract_version "$x")"
        [[ -n "$x" ]] || return 1
        koopa_print "$x"
    done
    return 0
}

koopa_macos_ifactive() {
    local app x
    declare -A app=(
        [ifconfig]="$(koopa_macos_locate_ifconfig)"
        [pcregrep]="$(koopa_locate_pcregrep)"
    )
    x="$( \
        "${app[ifconfig]}" \
            | "${app[pcregrep]}" -M -o '^[^\t:]+:([^\n]|\n\t)*status: active' \
    )"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}

koopa_macos_install_aws_cli() {
    koopa_install_app \
        --link-in-bin='bin/aws' \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --platform='macos' \
        "$@"
}

koopa_macos_install_neovim_binary() {
    koopa_install_app \
        --installer='neovim-binary' \
        --link-in-bin='bin/nvim' \
        --name-fancy='Neovim' \
        --name='neovim' \
        --platform='macos' \
        "$@"
}

koopa_macos_install_python_binary() {
    koopa_install_app \
        --installer='python-binary' \
        --link-in-bin='bin/python3' \
        --name-fancy='Python' \
        --name='python' \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        "$@"
}

koopa_macos_install_r_binary() {
    koopa_install_app \
        --installer='r-binary' \
        --link-in-bin='bin/R' \
        --link-in-bin='bin/Rscript' \
        --name-fancy='R' \
        --name='r' \
        --platform='macos' \
        --prefix="$(koopa_macos_r_prefix)" \
        --system \
        "$@"
}

koopa_macos_install_r_gfortran() {
    koopa_install_app \
        --name-fancy='R gfortran' \
        --name='r-gfortran' \
        --platform='macos' \
        --prefix='/usr/local/gfortran' \
        --system \
        "$@"
}

koopa_macos_install_r_openmp() {
    koopa_install_app \
        --name-fancy='R OpenMP' \
        --name='r-openmp' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_install_xcode_clt() {
    koopa_install_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_link_homebrew() {
    local dict
    declare -A dict
    koopa_assert_has_no_args "$#"
    koopa_link_in_bin \
        '/Applications/BBEdit.app/Contents/Helpers/bbedit_tool' \
        'bbedit'
    koopa_link_in_bin \
        '/Applications/Emacs.app/Contents/MacOS/Emacs' \
        'emacs'
    dict[r]="$(koopa_macos_r_prefix)"
    koopa_link_in_bin \
        "${dict[r]}/bin/R" 'R' \
        "${dict[r]}/bin/Rscript" 'Rscript'
    koopa_link_in_bin \
        '/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code' \
        'code'
}

koopa_macos_list_launch_agents() {
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [ls]="$(koopa_locate_ls)"
    )
    koopa_alert 'Listing launch agents and daemons.'
    "${app[ls]}" \
        --ignore='disabled' \
        "${HOME}/Library/LaunchAgents" \
        '/Library/LaunchAgents' \
        '/Library/LaunchDaemons' \
        '/Library/PrivilegedHelperTools'
    return 0
}

koopa_macos_locate_installer() {
    koopa_locate_app '/usr/sbin/installer'
}

koopa_macos_locate_automount() {
    koopa_locate_app '/usr/sbin/automount'
}

koopa_macos_locate_defaults() {
    koopa_locate_app '/usr/bin/defaults'
}

koopa_macos_locate_diskutil() {
    koopa_locate_app '/usr/sbin/diskutil'
}

koopa_macos_locate_dscacheutil() {
    koopa_locate_app '/usr/bin/dscacheutil'
}

koopa_macos_locate_fs_usage() {
    koopa_locate_app '/usr/bin/fs_usage'
}

koopa_macos_locate_hdiutil() {
    koopa_locate_app '/usr/bin/hdiutil'
}

koopa_macos_locate_ifconfig() {
    koopa_locate_app '/sbin/ifconfig'
}

koopa_macos_locate_kill_all() {
    koopa_locate_app '/usr/bin/killAll'
}

koopa_macos_locate_launchctl() {
    koopa_locate_app '/bin/launchctl'
}

koopa_macos_locate_lsregister() {
    koopa_locate_app "/System/Library/Frameworks/CoreServices.framework\
/Frameworks/LaunchServices.framework/Support/lsregister"
}

koopa_macos_locate_mount_nfs() {
    koopa_locate_app '/sbin/mount_nfs'
}

koopa_macos_locate_nfsstat() {
    koopa_locate_app '/usr/bin/nfsstat'
}

koopa_macos_locate_nvram() {
    koopa_locate_app '/usr/sbin/nvram'
}

koopa_macos_locate_open() {
    koopa_locate_app '/usr/bin/open'
}

koopa_macos_locate_otool() {
    koopa_locate_app '/usr/bin/otool'
}

koopa_macos_locate_pkgutil() {
    koopa_locate_app '/usr/sbin/pkgutil'
}

koopa_macos_locate_plistbuddy() {
    koopa_locate_app '/usr/libexec/PlistBuddy'
}

koopa_macos_locate_plutil() {
    koopa_locate_app '/usr/bin/plutil'
}

koopa_macos_locate_pmset() {
    koopa_locate_app '/usr/bin/pmset'
}

koopa_macos_locate_reboot() {
    koopa_locate_app '/sbin/reboot'
}

koopa_macos_locate_scutil() {
    koopa_locate_app '/usr/sbin/scutil'
}

koopa_macos_locate_softwareupdate() {
    koopa_locate_app '/usr/sbin/softwareupdate'
}

koopa_macos_locate_sw_vers() {
    koopa_locate_app '/usr/bin/sw_vers'
}

koopa_macos_locate_sysctl() {
    koopa_locate_app '/usr/sbin/sysctl'
}

koopa_macos_locate_xattr() {
    koopa_locate_app '/usr/bin/xattr'
}

koopa_macos_locate_xcode_select() {
    koopa_locate_app '/usr/bin/xcode-select'
}

koopa_macos_locate_xcodebuild() {
    koopa_locate_app '/usr/bin/xcodebuild'
}

koopa_macos_locate_xcrun() {
    koopa_locate_app '/usr/bin/xcrun'
}

koopa_macos_reload_autofs() {
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [automount]="$(koopa_macos_locate_automount)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[automount]}" -vc
    return 0
}

koopa_macos_spotlight_find() {
    local pattern x
    koopa_assert_has_args_le "$#" 2
    koopa_assert_is_installed 'mdfind'
    pattern="${1:?}"
    dir="${2:-.}"
    koopa_assert_is_dir "$dir"
    x="$( \
        mdfind \
            -name "$pattern" \
            -onlyin "$dir" \
    )"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}

koopa_macos_spotlight_usage() {
    declare -A app=(
        [fs_usage]="$(koopa_macos_locate_fs_usage)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[fs_usage]}" -w -f filesys mds
    return 0
}

koopa_macos_symlink_dropbox() {
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [kill_all]="$(koopa_macos_locate_kill_all)"
        [sudo]="$(koopa_locate_sudo)"
    )
    koopa_rm --sudo "${HOME}/Desktop"
    koopa_ln "${HOME}/Dropbox/Desktop" "${HOME}/."
    koopa_rm --sudo "${HOME}/Documents"
    koopa_ln "${HOME}/Dropbox/Documents" "${HOME}/."
    "${app[sudo]}" "${app[kill_all]}" 'Finder'
    return 0
}

koopa_macos_symlink_icloud_drive() {
    koopa_assert_has_no_args "$#"
    koopa_ln \
        "${HOME}/Library/Mobile Documents/com~apple~CloudDocs" \
        "${HOME}/icloud"
    return 0
}

koopa_macos_uninstall_adobe_creative_cloud() {
    koopa_uninstall_app \
        --name-fancy='Adobe Creative Cloud' \
        --name='adobe-creative-cloud' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_uninstall_brewfile_casks() {
    local app cask casks dict
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [brew]="$(koopa_locate_brew)"
        [cut]="$(koopa_locate_cut)"
    )
    declare -A dict=(
        [brewfile]="${1:?}"
    )
    readarray -t casks <<< "$( \
        koopa_grep \
            --file="${dict[brewfile]}" \
            --pattern='^cask\s"' \
            --regex \
        | "${app[cut]}" -d '"' -f '2' \
    )"
    for cask in "${casks[@]}"
    do
        "${app[brew]}" uninstall --cask --force "$cask"
    done
    return 0
}

koopa_macos_uninstall_cisco_webex() {
    koopa_uninstall_app \
        --name-fancy='Cisco WebEx' \
        --name='cisco-webex' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_uninstall_docker() {
    koopa_uninstall_app \
        --name-fancy='Docker' \
        --name='docker' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_uninstall_microsoft_onedrive() {
    koopa_uninstall_app \
        --name-fancy='Microsoft OneDrive' \
        --name='microsoft-onedrive' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_uninstall_oracle_java() {
    koopa_uninstall_app \
        --name-fancy='Oracle Java' \
        --name='oracle-java' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_uninstall_python_binary() {
    koopa_uninstall_app \
        --name-fancy='Python' \
        --name='python' \
        --platform='macos' \
        --prefix="$(koopa_macos_python_prefix)" \
        --system \
        --uninstaller='python-binary' \
        --unlink-in-bin='python3' \
        "$@"
}

koopa_macos_uninstall_r_binary() {
    koopa_uninstall_app \
        --name-fancy='R' \
        --name='r' \
        --platform='macos' \
        --system \
        --uninstaller='r-binary' \
        --unlink-in-bin='R' \
        --unlink-in-bin='Rscript' \
        "$@"
}

koopa_macos_uninstall_r_gfortran() {
    koopa_uninstall_app \
        --name-fancy='R gfortran' \
        --name='r-gfortran' \
        --platform='macos' \
        --prefix='/usr/local/gfortran' \
        --system \
        "$@"
}

koopa_macos_uninstall_r_openmp() {
    koopa_uninstall_app \
        --name-fancy='R OpenMP' \
        --name='r-openmp' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_uninstall_ringcentral() {
    koopa_uninstall_app \
        --name-fancy='RingCentral' \
        --name='ringcentral' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_uninstall_xcode_clt() {
    koopa_uninstall_app \
        --name-fancy='Xcode Command Line Tools (CLT)' \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_unlink_homebrew() {
    koopa_assert_has_no_args "$#"
    koopa_unlink_in_bin \
        'bbedit' \
        'code' \
        'emacs' \
        'gcloud' \
        'julia'
    return 0
}

koopa_macos_update_defaults() {
    koopa_update_app \
        --name-fancy='macOS defaults' \
        --name='defaults' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_update_microsoft_office() {
    local msupdate
    koopa_assert_has_no_args "$#"
    koopa_h1 "Updating Microsoft Office via 'msupdate'."
    msupdate="/Library/Application Support/Microsoft/MAU2.0/\
Microsoft AutoUpdate.app/Contents/MacOS/msupdate"
    "$msupdate" --install
    return 0
}

koopa_macos_update_system() {
    koopa_update_app \
        --name-fancy='macOS system' \
        --name='system' \
        --platform='macos' \
        --system \
        "$@"
}

koopa_macos_xcode_clt_version() {
    local app str
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [cut]="$(koopa_locate_cut)"
        [pkgutil]="$(koopa_macos_locate_pkgutil)"
    )
    [[ -x "${app[cut]}" ]] || return 1
    [[ -x "${app[pkgutil]}" ]] || return 1
    str="$( \
        "${app[pkgutil]}" --pkg-info='com.apple.pkg.CLTools_Executables' \
        | koopa_grep --pattern='^version:\s' --regex \
        | "${app[cut]}" -d ' ' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

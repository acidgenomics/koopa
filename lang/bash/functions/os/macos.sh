#!/usr/bin/env bash
# shellcheck disable=all

_koopa_macos_app_version() {
    local -A app
    _koopa_assert_has_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['plutil']="$(_koopa_macos_locate_plutil)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    for app in "$@"
    do
        local plist str
        plist="/Applications/${app}.app/Contents/Info.plist"
        [[ -f "$plist" ]] || return 1
        str="$( \
            "${app['plutil']}" -p "$plist" \
                | _koopa_grep --pattern='CFBundleShortVersionString' - \
                | "${app['awk']}" -F ' => ' '{print $2}' \
                | "${app['tr']}" --delete '\"' \
        )"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}

_koopa_macos_assert_is_xcode_clt_installed() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_macos_is_xcode_clt_installed
    then
        _koopa_stop \
            'Xcode Command Line Tools (CLT) are not installed.' \
            "Resolve with 'koopa install system xcode-clt'."
    fi
    return 0
}

_koopa_macos_brew_cask_outdated() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['keep_latest']=0
    dict['tmp_file']="$(_koopa_tmp_file)"
    script -q "${dict['tmp_file']}" \
        "${app['brew']}" outdated --cask --greedy >/dev/null
    if [[ "${dict['keep_latest']}" -eq 1 ]]
    then
        dict['str']="$("${app['cut']}" -d ' ' -f '1' < "${dict['tmp_file']}")"
    else
        dict['str']="$( \
            _koopa_grep \
                --file="${dict['tmp_file']}" \
                --fixed \
                --invert-match \
                --pattern='(latest)' \
            | "${app['cut']}" -d ' ' -f '1' \
        )"
    fi
    _koopa_rm "${dict['tmp_file']}"
    [[ -n "${dict['str']}" ]] || return 0
    _koopa_print "${dict['str']}"
    return 0
}

_koopa_macos_brew_cask_quarantine_fix() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['xattr']="$(_koopa_macos_locate_xattr)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo \
        "${app['xattr']}" -r -d \
            'com.apple.quarantine' \
            '/Applications/'*'.app'
    return 0
}

_koopa_macos_brew_cask_quarantine_support() {
    local -A app dict
    app['brew']="$(_koopa_locate_brew)"
    app['swift']="$(_koopa_locate_swift)"
    _koopa_assert_is_executable "${app[@]}"
    dict['repo']="$("${app['brew']}" --repo)"
    _koopa_assert_is_dir "${dict['repo']}"
    dict['file']="${dict['repo']}/Library/Homebrew/cask/utils/quarantine.swift"
    _koopa_assert_is_file "${dict['file']}"
    _koopa_alert "Running swift script at '${dict['file']}'."
    "${app['swift']}" "${dict['file']}"
    return 0
}

_koopa_macos_brew_upgrade_casks() {
    local -A app
    local -a casks
    local cask
    _koopa_assert_has_no_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert 'Checking casks.'
    readarray -t casks <<< "$(_koopa_macos_brew_cask_outdated)"
    if _koopa_is_array_empty "${casks[@]:-}"
    then
        return 0
    fi
    _koopa_dl \
        "$(_koopa_ngettext \
            --num="${#casks[@]}" \
            --msg1='outdated cask' \
            --msg2='outdated casks' \
        )" \
        "$(_koopa_to_string "${casks[@]}")"
    _koopa_sudo_trigger
    "${app['brew']}" reinstall --cask --force "${casks[@]}"
    for cask in "${casks[@]}"
    do
        case "$cask" in
            'gpg-suite'*)
                _koopa_macos_disable_gpg_updater
                ;;
            'r')
                app['r']="$(_koopa_macos_r_prefix)/bin/R"
                _koopa_configure_r "${app['r']}"
                ;;
        esac
    done
    return 0
}

_koopa_macos_clean_launch_services() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    app['lsregister']="$(_koopa_macos_locate_lsregister)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert "Cleaning LaunchServices 'Open With' menu."
    "${app['lsregister']}" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    _koopa_sudo "${app['lsregister']}" \
        -kill \
        -lint \
        -seed \
        -f \
        -r \
        -v \
        -dump \
        -domain 'local' \
        -domain 'network' \
        -domain 'system' \
        -domain 'user'
    _koopa_sudo "${app['kill_all']}" 'Finder'
    _koopa_sudo "${app['kill_all']}" 'Dock'
    _koopa_alert_success 'Clean up was successful.'
    return 0
}

_koopa_macos_configure_system_preferences() {
    _koopa_configure_app \
        --name='preferences' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_configure_user_preferences() {
    _koopa_configure_app \
        --name='preferences' \
        --platform='macos' \
        --user \
        "$@"
}

_koopa_macos_create_dmg() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['hdiutil']="$(_koopa_macos_locate_hdiutil)"
    _koopa_assert_is_executable "${app[@]}"
    dict['srcfolder']="${1:?}"
    _koopa_assert_is_dir "${dict['srcfolder']}"
    dict['srcfolder']="$(_koopa_realpath "${dict['srcfolder']}")"
    dict['volname']="$(_koopa_basename "${dict['volname']}")"
    dict['ov']="${dict['volname']}.dmg"
    "${app['hdiutil']}" create \
        -ov "${dict['ov']}" \
        -srcfolder "${dict['srcfolder']}" \
        -volname "${dict['volname']}"
    return 0
}

_koopa_macos_disable_crashplan() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_disable_plist_file \
        "${HOME:?}/Library/LaunchAgents/com.code42.menubar.plist" \
        '/Library/LaunchDaemons/com.code42.service.plist'
    return 0
}

_koopa_macos_disable_google_keystone() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_disable_plist_file \
        '/Library/LaunchAgents/com.google.keystone.agent.plist' \
        '/Library/LaunchAgents/com.google.keystone.xpcservice.plist' \
        '/Library/LaunchDaemons/com.google.keystone.daemon.plist'
    return 0
}

_koopa_macos_disable_gpg_updater() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_disable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}

_koopa_macos_disable_microsoft_defender() {
    local -A app
    local -a plist_files
    _koopa_assert_has_no_args "$#"
    app['systemextensionsctl']="$(_koopa_macos_locate_systemextensionsctl)"
    _koopa_assert_is_executable "${app[@]}"
    plist_files=(
        '/Library/LaunchAgents/com.microsoft.dlp.agent.plist'
        '/Library/LaunchAgents/com.microsoft.wdav.tray.plist'
        '/Library/LaunchDaemons/com.microsoft.dlp.daemon.plist'
        '/Library/LaunchDaemons/com.microsoft.fresno.plist'
        '/Library/LaunchDaemons/com.microsoft.fresno.uninstall.plist'
    )
    _koopa_macos_disable_plist_file "${plist_files[@]}"
    "${app['systemextensionsctl']}" list
    _koopa_alert_note "Reboot to disable \
Microsoft Defender Endpoint Security Extension (com.microsoft.wdav.epsext) and \
Microsoft Defender Network Extension (com.microsoft.wdav.netext)."
    return 0
}

_koopa_macos_disable_microsoft_teams_updater() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_disable_plist_file \
        '/Library/LaunchDaemons/com.microsoft.teams.TeamsUpdaterDaemon.plist'
    return 0
}

_koopa_macos_disable_plist_file() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['launchctl']="$(_koopa_macos_locate_launchctl)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_file "$@"
    for file in "$@"
    do
        local -A bool dict
        bool['daemon']=0
        bool['sudo']=1
        dict['enabled_file']="$file"
        dict['disabled_file']="$(_koopa_dirname "${dict['enabled_file']}")/\
disabled/$(_koopa_basename "${dict['enabled_file']}")"
        _koopa_alert "Disabling '${dict['enabled_file']}'."
        if _koopa_str_detect_fixed \
            --string="${dict['enabled_file']}" \
            --pattern='/LaunchDaemons/'
        then
            bool['daemon']=1
        fi
        if _koopa_str_detect_regex \
            --string="${dict['enabled_file']}" \
            --pattern="^${HOME:?}"
        then
            bool['sudo']=0
        fi
        if [[ "${bool['sudo']}" -eq 1 ]]
        then
            _koopa_assert_is_admin
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                _koopa_alert "Unloading '${dict['enabled_file']}'."
                _koopa_sudo \
                    "${app['launchctl']}" unload -w "${dict['enabled_file']}"
            fi
            _koopa_mv --sudo --verbose \
                "${dict['enabled_file']}" \
                "${dict['disabled_file']}"
        else
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                _koopa_alert "Unloading '${dict['enabled_file']}'."
                "${app['launchctl']}" unload -w "${dict['enabled_file']}"
            fi
            _koopa_mv --verbose \
                "${dict['enabled_file']}" \
                "${dict['disabled_file']}"
        fi
    done
    return 0
}

_koopa_macos_disable_privileged_helper_tool() {
    local bn
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    for bn in "$@"
    do
        local -A dict
        dict['enabled_file']="/Library/PrivilegedHelperTools/${bn}"
        dict['disabled_file']="$(_koopa_dirname "${dict['enabled_file']}")/\
disabled/$(_koopa_basename "${dict['enabled_file']}")"
        _koopa_assert_is_file "${dict['enabled_file']}"
        _koopa_assert_is_not_file "${dict['disabled_file']}"
        _koopa_alert "Disabling '${dict['disabled_file']}'."
        _koopa_mv --sudo "${dict['enabled_file']}" "${dict['disabled_file']}"
    done
    return 0
}

_koopa_macos_disable_spotlight_indexing() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['mdutil']="$(_koopa_macos_locate_mdutil)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['mdutil']}" -a -i off
    "${app['mdutil']}" -a -s
    return 0
}

_koopa_macos_disable_touch_id_sudo() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    dict['file']='/etc/pam.d/sudo'
    if [[ -f "${dict['file']}" ]] && \
        ! _koopa_file_detect_fixed \
            --file="${dict['file']}" \
            --pattern='pam_tid.so'
    then
        _koopa_alert_note "Touch ID not enabled in '${dict['file']}'."
        return 0
    fi
    _koopa_alert "Disabling Touch ID defined in '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
END
    _koopa_chmod --sudo '0444' "${dict['file']}"
    _koopa_alert_success 'Touch ID disabled for sudo.'
    return 0
}

_koopa_macos_disable_zoom_daemon() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_disable_plist_file \
        '/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist'
    _koopa_macos_disable_privileged_helper_tool \
        'us.zoom.ZoomDaemon'
}

_koopa_macos_download_macos() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['softwareupdate']="$(_koopa_macos_locate_softwareupdate)"
    _koopa_assert_is_executable "${app[@]}"
    dict['version']="${1:?}"
    "${app['softwareupdate']}" \
        --fetch-full-installer \
        --full-installer-version "${dict['version']}"
    return 0
}

_koopa_macos_enable_crashplan() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_enable_plist_file \
        "${HOME:?}/Library/LaunchAgents/com.code42.menubar.plist" \
        '/Library/LaunchDaemons/com.code42.service.plist'
    return 0
}

_koopa_macos_enable_google_keystone() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_enable_plist_file \
        '/Library/LaunchAgents/com.google.keystone.agent.plist' \
        '/Library/LaunchAgents/com.google.keystone.xpcservice.plist' \
        '/Library/LaunchDaemons/com.google.keystone.daemon.plist'
    return 0
}

_koopa_macos_enable_gpg_updater() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_enable_plist_file \
        '/Library/LaunchAgents/org.gpgtools.updater.plist'
}

_koopa_macos_enable_microsoft_defender() {
    local -A app
    local -a plist_files
    _koopa_assert_has_no_args "$#"
    app['systemextensionsctl']="$(_koopa_macos_locate_systemextensionsctl)"
    _koopa_assert_is_executable "${app[@]}"
    plist_files=(
        '/Library/LaunchAgents/com.microsoft.dlp.agent.plist'
        '/Library/LaunchAgents/com.microsoft.wdav.tray.plist'
        '/Library/LaunchDaemons/com.microsoft.dlp.daemon.plist'
        '/Library/LaunchDaemons/com.microsoft.fresno.plist'
        '/Library/LaunchDaemons/com.microsoft.fresno.uninstall.plist'
    )
    _koopa_macos_enable_plist_file "${plist_files[@]}"
    "${app['systemextensionsctl']}" list
    return 0
}

_koopa_macos_enable_microsoft_teams_updater() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_enable_plist_file \
        '/Library/LaunchDaemons/com.microsoft.teams.TeamsUpdaterDaemon.plist'
    return 0
}

_koopa_macos_enable_plist_file() {
    local -A app
    local file
    _koopa_assert_has_args "$#"
    app['launchctl']="$(_koopa_macos_locate_launchctl)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_not_file "$@"
    for file in "$@"
    do
        local -A bool dict
        bool['daemon']=0
        bool['sudo']=1
        dict['enabled_file']="$file"
        dict['disabled_file']="$(_koopa_dirname "${dict['enabled_file']}")/\
disabled/$(_koopa_basename "${dict['enabled_file']}")"
        _koopa_alert "Enabling '${dict['enabled_file']}'."
        if _koopa_str_detect_fixed \
            --string="${dict['enabled_file']}" \
            --pattern='/LaunchDaemons/'
        then
            bool['daemon']=1
        fi
        if _koopa_str_detect_regex \
            --string="${dict['enabled_file']}" \
            --pattern="^${HOME:?}"
        then
            bool['sudo']=0
        fi
        if [[ "${bool['sudo']}" -eq 1 ]]
        then
            _koopa_assert_is_admin
            _koopa_mv --sudo --verbose \
                "${dict['disabled_file']}" \
                "${dict['enabled_file']}"
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                _koopa_alert "Loading '${dict['enabled_file']}'."
                _koopa_sudo \
                    "${app['launchctl']}" load -w "${dict['enabled_file']}"
            fi
        else
            _koopa_mv --verbose \
                "${dict['disabled_file']}" \
                "${dict['enabled_file']}"
            if [[ "${bool['daemon']}" -eq 1 ]]
            then
                _koopa_alert "Loading '${dict['enabled_file']}'."
                "${app['launchctl']}" load -w "${dict['enabled_file']}"
            fi
        fi
    done
    return 0
}

_koopa_macos_enable_privileged_helper_tool() {
    local bn
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    for bn in "$@"
    do
        local -A dict
        dict['enabled_file']="/Library/PrivilegedHelperTools/${bn}"
        dict['disabled_file']="$(_koopa_dirname "${dict['enabled_file']}")/\
disabled/$(_koopa_basename "${dict['enabled_file']}")"
        _koopa_assert_is_not_file "${dict['enabled_file']}"
        _koopa_assert_is_file "${dict['disabled_file']}"
        _koopa_alert "Enabling '${dict['disabled_file']}'."
        _koopa_mv --sudo "${dict['disabled_file']}" "${dict['enabled_file']}"
    done
    return 0
}

_koopa_macos_enable_spotlight_indexing() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['mdutil']="$(_koopa_macos_locate_mdutil)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['mdutil']}" -a -i on
    "${app['mdutil']}" -a -s
    return 0
}

_koopa_macos_enable_touch_id_sudo() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    dict['file']='/etc/pam.d/sudo'
    if [[ -f "${dict['file']}" ]] && \
        _koopa_file_detect_fixed \
            --file="${dict['file']}" \
            --pattern='pam_tid.so'
    then
        _koopa_alert_note "Touch ID already enabled in '${dict['file']}'."
        return 0
    fi
    app['chflags']="$(_koopa_macos_locate_chflags)"
    app['sudo']="$(_koopa_locate_sudo)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert "Enabling Touch ID in '${dict['file']}'."
    read -r -d '' "dict[string]" << END || true
auth       sufficient     pam_tid.so
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
END
    "${app['sudo']}" "${app['chflags']}" noschg "${dict['file']}"
    _koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    _koopa_chmod --sudo '0444' "${dict['file']}"
    "${app['sudo']}" "${app['chflags']}" schg "${dict['file']}"
    _koopa_alert_success 'Touch ID enabled for sudo.'
    return 0
}

_koopa_macos_enable_zoom_daemon() {
    _koopa_assert_has_no_args "$#"
    _koopa_macos_enable_plist_file \
        '/Library/LaunchDaemons/us.zoom.ZoomDaemon.plist'
    _koopa_macos_enable_privileged_helper_tool \
        'us.zoom.ZoomDaemon'
}

_koopa_macos_finder_hide() {
    local -A app
    _koopa_assert_has_args "$#"
    app['setfile']="$(_koopa_macos_locate_setfile)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_existing "$@"
    "${app['setfile']}" -a V "$@"
    return 0
}

_koopa_macos_finder_unhide() {
    local -A app
    _koopa_assert_has_args "$#"
    app['setfile']="$(_koopa_macos_locate_setfile)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_assert_is_existing "$@"
    "${app['setfile']}" -a v "$@"
    return 0
}

_koopa_macos_flush_dns() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['dscacheutil']="$(_koopa_macos_locate_dscacheutil)"
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_alert 'Flushing DNS.'
    _koopa_sudo "${app['dscacheutil']}" -flushcache
    _koopa_sudo "${app['kill_all']}" -HUP 'mDNSResponder'
    _koopa_alert_success 'DNS flush was successful.'
    return 0
}

_koopa_macos_force_eject() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    _koopa_assert_is_admin
    app['diskutil']="$(_koopa_macos_locate_diskutil)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']="${1:?}"
    dict['mount']="/Volumes/${dict['name']}"
    _koopa_assert_is_dir "${dict['mount']}"
    _koopa_sudo "${app['diskutil']}" unmount force "${dict['mount']}"
    return 0
}

_koopa_macos_force_reset_icloud_drive() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    app['reboot']="$(_koopa_macos_locate_reboot)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['kill_all']}" bird
    _koopa_rm \
        "${HOME:?}/Library/Application Support/CloudDocs" \
        "${HOME:?}/Library/Caches/"*
    _koopa_sudo "${app['reboot']}" now
    return 0
}

_koopa_macos_homebrew_cask_version() {
    local -A app
    local cask
    _koopa_assert_has_args "$#"
    app['brew']="$(_koopa_locate_brew)"
    _koopa_assert_is_executable "${app[@]}"
    for cask in "$@"
    do
        local str
        str="$("${app['brew']}" info --cask "$cask")"
        str="$(_koopa_extract_version "$str")"
        [[ -n "$str" ]] || return 1
        _koopa_print "$str"
    done
    return 0
}

_koopa_macos_ifactive() {
    local -A app
    local str
    app['ifconfig']="$(_koopa_macos_locate_ifconfig)"
    app['pcregrep']="$(_koopa_locate_pcregrep)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['ifconfig']}" \
            | "${app['pcregrep']}" -M -o \
                '^[^\t:]+:([^\n]|\n\t)*status: active' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_macos_install_system_python() {
    local -A dict
    dict['python_version']="$(_koopa_python_major_minor_version)"
    _koopa_install_app \
        --installer='python' \
        --name="python${dict['python_version']}" \
        --platform='macos' \
        --prefix="$(_koopa_macos_python_prefix)" \
        --system \
        "$@"
}

_koopa_macos_install_system_r_gfortran() {
    _koopa_install_app \
        --name='r-gfortran' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_install_system_r_xcode_openmp() {
    _koopa_install_app \
        --name='r-xcode-openmp' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_install_system_r() {
    _koopa_install_app \
        --name='r' \
        --platform='macos' \
        --prefix="$(_koopa_macos_r_prefix)" \
        --system \
        "$@"
}

_koopa_macos_install_system_rosetta() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['softwareupdate']="$(_koopa_macos_locate_softwareupdate)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['softwareupdate']}" \
        --install-rosetta \
        --agree-to-license
    return 0
}

_koopa_macos_install_system_xcode_clt() {
    _koopa_install_app \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_is_xcode_clt_installed() {
    _koopa_assert_has_no_args "$#"
    [[ -d '/Library/Developer/CommandLineTools/usr/bin' ]]
}

_koopa_macos_list_app_store_apps() {
    local -A app
    local string
    app['find']="$(_koopa_locate_find --allow-system)"
    app['sed']="$(_koopa_locate_sed --allow-system)"
    app['sort']="$(_koopa_locate_sort --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    string="$( \
        "${app['find']}" \
            '/Applications' \
            -maxdepth 4 \
            -path '*Contents/_MASReceipt/receipt' \
            -print \
        | "${app['sed']}" \
            -e 's#.app/Contents/_MASReceipt/receipt#.app#g' \
            -e 's#/Applications/##' \
        | "${app['sort']}" \
    )"
    [[ -n "$string" ]] || return 1
    _koopa_print "$string"
    return 0
}

_koopa_macos_list_launch_agents() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['ls']="$(_koopa_locate_ls)"
    _koopa_assert_is_executable "${app[@]}"
    "${app['ls']}" \
        --ignore='disabled' \
        "${HOME}/Library/LaunchAgents" \
        '/Library/LaunchAgents' \
        '/Library/LaunchDaemons' \
        '/Library/PrivilegedHelperTools'
    return 0
}

_koopa_macos_locate_automount() {
    _koopa_locate_app \
        '/usr/sbin/automount' \
        "$@"
}

_koopa_macos_locate_chflags() {
    _koopa_locate_app \
        '/usr/bin/chflags' \
        "$@"
}

_koopa_macos_locate_defaults() {
    _koopa_locate_app \
        '/usr/bin/defaults' \
        "$@"
}

_koopa_macos_locate_diskutil() {
    _koopa_locate_app \
        '/usr/sbin/diskutil' \
        "$@"
}

_koopa_macos_locate_dot_clean() {
    _koopa_locate_app \
        '/usr/sbin/dot_clean' \
        "$@"
}

_koopa_macos_locate_dscacheutil() {
    _koopa_locate_app \
        '/usr/bin/dscacheutil' \
        "$@"
}

_koopa_macos_locate_fs_usage() {
    _koopa_locate_app \
        '/usr/bin/fs_usage' \
        "$@"
}

_koopa_macos_locate_hdiutil() {
    _koopa_locate_app \
        '/usr/bin/hdiutil' \
        "$@"
}

_koopa_macos_locate_ifconfig() {
    _koopa_locate_app \
        '/sbin/ifconfig' \
        "$@"
}

_koopa_macos_locate_installer() {
    _koopa_locate_app \
        '/usr/sbin/installer' \
        "$@"
}

_koopa_macos_locate_kill_all() {
    _koopa_locate_app \
        '/usr/bin/killAll' \
        "$@"
}

_koopa_macos_locate_launchctl() {
    _koopa_locate_app \
        '/bin/launchctl' \
        "$@"
}

_koopa_macos_locate_ld_classic() {
    _koopa_locate_app \
        '/Library/Developer/CommandLineTools/usr/bin/ld-classic' \
        "$@"
}

_koopa_macos_locate_lsregister() {
    _koopa_locate_app \
        "/System/Library/Frameworks/CoreServices.framework\
/Frameworks/LaunchServices.framework/Support/lsregister" \
        "$@"
}

_koopa_macos_locate_mdutil() {
    _koopa_locate_app \
        '/usr/bin/mdutil' \
        "$@"
}

_koopa_macos_locate_mount_nfs() {
    _koopa_locate_app \
        '/sbin/mount_nfs' \
        "$@"
}

_koopa_macos_locate_nfsstat() {
    _koopa_locate_app \
        '/usr/bin/nfsstat' \
        "$@"
}

_koopa_macos_locate_nvram() {
    _koopa_locate_app \
        '/usr/sbin/nvram' \
        "$@"
}

_koopa_macos_locate_open() {
    _koopa_locate_app \
        '/usr/bin/open' \
        "$@"
}

_koopa_macos_locate_otool() {
    _koopa_locate_app \
        '/usr/bin/otool' \
        "$@"
}

_koopa_macos_locate_pkgutil() {
    _koopa_locate_app \
        '/usr/sbin/pkgutil' \
        "$@"
}

_koopa_macos_locate_plistbuddy() {
    _koopa_locate_app \
        '/usr/libexec/PlistBuddy' \
        "$@"
}

_koopa_macos_locate_plutil() {
    _koopa_locate_app \
        '/usr/bin/plutil' \
        "$@"
}

_koopa_macos_locate_pmset() {
    _koopa_locate_app \
        '/usr/bin/pmset' \
        "$@"
}

_koopa_macos_locate_reboot() {
    _koopa_locate_app \
        '/sbin/reboot' \
        "$@"
}

_koopa_macos_locate_rpcinfo() {
    _koopa_locate_app \
        '/usr/sbin/rpcinfo' \
        "$@"
}

_koopa_macos_locate_scutil() {
    _koopa_locate_app \
        '/usr/sbin/scutil' \
        "$@"
}

_koopa_macos_locate_softwareupdate() {
    _koopa_locate_app \
        '/usr/sbin/softwareupdate' \
        "$@"
}

_koopa_macos_locate_sw_vers() {
    _koopa_locate_app \
        '/usr/bin/sw_vers' \
        "$@"
}

_koopa_macos_locate_sysctl() {
    _koopa_locate_app \
        '/usr/sbin/sysctl' \
        "$@"
}

_koopa_macos_locate_systemextensionsctl() {
    _koopa_locate_app \
        '/usr/bin/systemextensionsctl' \
        "$@"
}

_koopa_macos_locate_systemsetup() {
    _koopa_locate_app \
        '/usr/sbin/systemsetup' \
        "$@"
}

_koopa_macos_locate_tmutil() {
    _koopa_locate_app \
        '/usr/bin/tmutil' \
        "$@"
}

_koopa_macos_locate_xattr() {
    _koopa_locate_app \
        '/usr/bin/xattr' \
        "$@"
}

_koopa_macos_locate_xcode_select() {
    _koopa_locate_app \
        '/usr/bin/xcode-select' \
        "$@"
}

_koopa_macos_locate_xcodebuild() {
    _koopa_locate_app \
        '/usr/bin/xcodebuild' \
        "$@"
}

_koopa_macos_locate_xcrun() {
    _koopa_locate_app \
        '/usr/bin/xcrun' \
        "$@"
}

_koopa_macos_os_codename() {
    local -A dict
    dict['version']="$(_koopa_macos_os_version)"
    case "${dict['version']}" in
        '26.'*)
            dict['string']='Tahoe'
            ;;
        '15.'*)
            dict['string']='Sequoia'
            ;;
        '14.'*)
            dict['string']='Sonoma'
            ;;
        '13.'*)
            dict['string']='Ventura'
            ;;
        '12.'*)
            dict['string']='Monterey'
            ;;
        '11.'*)
            dict['string']='Big Sur'
            ;;
        '10.15.'*)
            dict['string']='Catalina'
            ;;
        '10.14.'*)
            dict['string']='Mojave'
            ;;
        '10.13.'*)
            dict['string']='High Sierra'
            ;;
        '10.12.'*)
            dict['string']='Sierra'
            ;;
        '10.11.'*)
            dict['string']='El Capitan'
            ;;
        '10.10.'*)
            dict['string']='Yosmite'
            ;;
        '10.9.'*)
            dict['string']='Mavericks'
            ;;
        '10.8.'*)
            dict['string']='Mountain Lion'
            ;;
        '10.7.'*)
            dict['string']='Lion'
            ;;
        '10.6.'*)
            dict['string']='Snow Leopard'
            ;;
        '10.5.'*)
            dict['string']='Leopard'
            ;;
        '10.4.'*)
            dict['string']='Tiger'
            ;;
        '10.3.'*)
            dict['string']='Panther'
            ;;
        '10.2.'*)
            dict['string']='Jaguar'
            ;;
        '10.1.'*)
            dict['string']='Puma'
            ;;
        '10.0.'*)
            dict['string']='Cheetah'
            ;;
        *)
            return 1
            ;;
    esac
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_macos_os_version() {
    local str
    str="$(/usr/bin/sw_vers -productVersion)"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_macos_python_prefix() {
    _koopa_print '/Library/Frameworks/Python.framework/Versions/Current'
    return 0
}

_koopa_macos_r_prefix() {
    _koopa_print '/Library/Frameworks/R.framework/Versions/Current/Resources'
    return 0
}

_koopa_macos_reload_autofs() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['automount']="$(_koopa_macos_locate_automount)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['automount']}" -vc
    return 0
}

_koopa_macos_sdk_prefix() {
    _koopa_print '/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk'
    return 0
}

_koopa_macos_spotlight_find() {
    local pattern x
    _koopa_assert_has_args_le "$#" 2
    _koopa_assert_is_installed 'mdfind'
    pattern="${1:?}"
    dir="${2:-.}"
    _koopa_assert_is_dir "$dir"
    x="$( \
        mdfind \
            -name "$pattern" \
            -onlyin "$dir" \
    )"
    [[ -n "$x" ]] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_macos_spotlight_usage() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['fs_usage']="$(_koopa_macos_locate_fs_usage)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['fs_usage']}" -w -f filesys mds
    return 0
}

_koopa_macos_symlink_dropbox() {
    local -A app
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['kill_all']="$(_koopa_macos_locate_kill_all)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_rm --sudo "${HOME}/Desktop"
    _koopa_ln "${HOME}/Dropbox/Desktop" "${HOME}/."
    _koopa_rm --sudo "${HOME}/Documents"
    _koopa_ln "${HOME}/Dropbox/Documents" "${HOME}/."
    _koopa_sudo "${app['kill_all']}" 'Finder'
    return 0
}

_koopa_macos_symlink_icloud_drive() {
    _koopa_assert_has_no_args "$#"
    _koopa_ln \
        "${HOME}/Library/Mobile Documents/com~apple~CloudDocs" \
        "${HOME}/icloud"
    return 0
}

_koopa_macos_uninstall_brewfile_casks() {
    local -A app dict
    local -a casks
    local cask
    _koopa_assert_has_args_eq "$#" 1
    app['brew']="$(_koopa_locate_brew)"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['brewfile']="${1:?}"
    readarray -t casks <<< "$( \
        _koopa_grep \
            --file="${dict['brewfile']}" \
            --pattern='^cask\s"' \
            --regex \
        | "${app['cut']}" -d '"' -f '2' \
    )"
    for cask in "${casks[@]}"
    do
        "${app['brew']}" uninstall --cask --force "$cask"
    done
    return 0
}

_koopa_macos_uninstall_system_adobe_creative_cloud() {
    _koopa_uninstall_app \
        --name='adobe-creative-cloud' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_uninstall_system_cisco_webex() {
    _koopa_uninstall_app \
        --name='cisco-webex' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_uninstall_system_docker() {
    _koopa_uninstall_app \
        --name='docker' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_uninstall_system_microsoft_onedrive() {
    _koopa_uninstall_app \
        --name='microsoft-onedrive' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_uninstall_system_oracle_java() {
    _koopa_uninstall_app \
        --name='oracle-java' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_uninstall_system_python() {
    local -A dict
    dict['python_version']="$(_koopa_python_major_minor_version)"
    _koopa_uninstall_app \
        --name="python${dict['python_version']}" \
        --platform='macos' \
        --system \
        --uninstaller='python' \
        "$@"
}

_koopa_macos_uninstall_system_r_gfortran() {
    _koopa_uninstall_app \
        --name='r-gfortran' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_uninstall_system_r_xcode_openmp() {
    _koopa_uninstall_app \
        --name='r-xcode-openmp' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_uninstall_system_r() {
    _koopa_uninstall_app \
        --name='r' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_uninstall_ringcentral() {
    _koopa_uninstall_app \
        --name='ringcentral' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_uninstall_system_xcode_clt() {
    _koopa_uninstall_app \
        --name='xcode-clt' \
        --platform='macos' \
        --system \
        "$@"
}

_koopa_macos_xcode_clt_version() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['cut']="$(_koopa_locate_cut --allow-system)"
    app['pkgutil']="$(_koopa_macos_locate_pkgutil)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['pkgutil']}" --pkg-info='com.apple.pkg.CLTools_Executables' \
        | _koopa_grep --pattern='^version:\s' --regex \
        | "${app['cut']}" -d ' ' -f '2' \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

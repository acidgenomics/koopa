#!/usr/bin/env bash

koopa::macos_create_dmg() {
    # """
    # Create DMG image.
    # @note Updated 2020-07-15.
    # """
    local dir name
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_installed hdiutil
    dir="${1:?}"
    koopa::assert_is_dir "$dir"
    dir="$(realpath "$dir")"
    name="$(basename "$dir")"
    hdiutil create -volname "$name" -srcfolder "$dir" -ov "${name}.dmg"
    return 0
}

koopa::macos_clean_launch_services() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::h1 'Cleaning LaunchServices "Open With" menu.'
    "/System/Library/Frameworks/CoreServices.framework/Frameworks/\
LaunchServices.framework/Support/lsregister" \
        -kill \
        -r \
        -domain 'local' \
        -domain 'system' \
        -domain 'user'
    killall Finder
    koopa::success 'Clean up was successful.'
    return 0
}

koopa::macos_ifactive() {
    # """
    # Display active interfaces.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_is_installed ifconfig pcregrep
    ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'
    return 0
}

koopa::macos_install_pytaglib() {
    # """
    # Install pytaglib.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed brew pip
    brew install taglib &>/dev/null
    pip install \
        --global-option='build_ext' \
        --global-option='-I/usr/local/include/' \
        --global-option='-L/usr/local/lib' \
        pytaglib
    return 0
}

koopa::macos_install_r_sf() {
    # """
    # Install R sf package.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    koopa::is_r_package_installed sf && return 0
    Rscript -e "\
        install.packages(
            pkgs = \"sf\",
            type = \"source\",
            configure.args = paste(
                \"--with-gdal-config=/usr/local/opt/gdal/bin/gdal-config\",
                \"--with-geos-config=/usr/local/opt/geos/bin/geos-config\",
                \"--with-proj-data=/usr/local/opt/proj/share/proj\",
                \"--with-proj-include=/usr/local/opt/proj/include\",
                \"--with-proj-lib=/usr/local/opt/proj/lib\",
                \"--with-proj-share=/usr/local/opt/proj/share\"
            )
        )"
    return 0
}

koopa::macos_install_r_units() {
    # """
    # Install R units package.
    # @note Updated 2020-07-16.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    koopa::is_r_package_installed units && return 0
    Rscript -e "\
        install.packages(
            pkgs = \"units\",
            type = \"source\",
            configure.args = c(
                \"--with-udunits2-lib=/usr/local/lib\",
                \"--with-udunits2-include=/usr/include/udunits2\"
            )
        )"
    return 0
}

koopa::macos_install_r_xml() {
    # """
    # Install R XML package.
    # @note Updated 2020-07-16.
    #
    # Note that CRAN recommended clang7 compiler doesn't currently work.
    # CC="/usr/local/clang7/bin/clang"
    # > brew info gcc
    # > brew info libxml2
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed Rscript
    koopa::is_r_package_installed XML && return 0
    Rscript -e "\
        install.packages(
            pkgs = \"XML\",
            type = \"source\",
            configure.vars = c(
                \"CC=/usr/local/opt/gcc/bin/gcc-9\",
                \"XML_CONFIG=/usr/local/opt/libxml2/bin/xml2-config\"
            )
        )"
    return 0
}

koopa::macos_list_launch_agents() {
    koopa::assert_has_no_args "$#"
    koopa::h1 'Listing launch agents and daemons.'
    ls \
        "${HOME}/Library/LaunchAgents" \
        '/Library/LaunchAgents' \
        '/Library/LaunchDaemons' \
        '/Library/PrivilegedHelperTools'
    return 0
}

koopa::macos_merge_pdf() {
    # """
    # Merge PDF files, preserving hyperlinks
    # @note Updated 2020-07-16.
    #
    # @usage merge-pdf input{1,2,3}.pdf
    #
    # Modified version of:
    # https://github.com/mathiasbynens/dotfiles/blob/main/.aliases
    # """
    koopa::assert_has_args "$#"
    koopa::assert_is_installed gs
    koopa::assert_is_file "$@"
    gs \
        -dBATCH \
        -dNOPAUSE \
        -q \
        -sDEVICE='pdfwrite' \
        -sOutputFile='merge.pdf' \
        "$@"
    return 0
}

koopa::macos_open_app() {
    # """
    # Open a macOS GUI application.
    # @note Updated 2020-07-16.
    # """
    local name
    koopa::assert_has_args_eq "$#" 1
    name="${1:?}"
    open -a "${name}.app"
    return 0
}

koopa::macos_symlink_icloud_drive() {
    koopa::assert_has_no_args "$#"
    koopa::ln \
        "${HOME}/Library/Mobile Documents/com~apple~CloudDocs" \
        "${HOME}/icloud"
    return 0
}

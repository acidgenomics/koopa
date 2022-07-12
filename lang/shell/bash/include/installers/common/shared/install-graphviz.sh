#!/usr/bin/env bash

main() {
    # """
    # Install graphviz.
    # @note Updated 2022-07-12.
    #
    # @seealso
    # - https://graphviz.org/
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/
    #     graphviz.rb
    # - https://ports.macports.org/port/graphviz/details/
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [make]="$(koopa_locate_make)"
    )
    [[ -x "${app[make]}" ]] || return 1
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [name]='graphviz'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[file]="${dict[name]}-${dict[version]}.tar.xz"
    dict[url]="https://gitlab.com/api/v4/projects/4207231/packages/generic/\
${dict[name]}-releases/${dict[version]}/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    koopa_extract "${dict[file]}"
    koopa_cd "${dict[name]}-${dict[version]}"
    conf_args=(
        # Optional features:
        # > --enable-ltdl-install   install libltdl
        # > --enable-ltdl           support on-demand plugin loading
        # > --enable-swig=yes       swig-generated language bindings
        # > --enable-sharp=yes      C# language bindings
        # > --enable-d=no           d language bindings
        # > --enable-go=yes         go language bindings
        # > --enable-guile=yes      guile language bindings
        # > --enable-io=no          io language bindings
        # > --enable-java=yes       java language bindings
        # > --enable-javascript=no  Javascript language bindings
        # > --enable-lua=yes        lua language bindings
        # > --enable-ocaml=yes      ocaml language bindings
        # > --enable-perl=yes       perl language bindings
        # > --enable-php=yes        php language bindings
        # > --enable-python=yes     python language bindings
        # > --enable-python3=yes    python3 language bindings
        # > --enable-r=yes          R language bindings
        # > --enable-ruby=yes       ruby language bindings
        # > --enable-tcl=yes        tcl language bindings
        #
        # Optional packages:
        # > --with-pic[=PKGS]       try to use only PIC/non-PIC objects
        # > --with-aix-soname=aix|svr4|both
        # > --with-gnu-ld           assume the C compiler uses GNU ld
        # > --with-sysroot[=DIR]    Search for dependent libraries within DIR
        # > --with-demos=DIR        Install demos
        # > --with-pkgconfigdir     pkg-config installation directory
        # > --with-tclsh=PROG       use a specific tclsh
        # > --with-included-ltdl    use the GNU ltdl sources included here
        # > --with-ltdl-include=DIR use the ltdl headers installed in DIR
        # > --with-ltdl-lib=DIR     use the libltdl.la installed in DIR
        # > --with-x                use the X Window System
        # > --with-javaincludedir=DIR
        # > --with-javalibdir=DIR   use JAVA libraries from DIR
        # > --with-extraincludedir=DIR
        # > --with-extralibdir=DIR  use extra libraries from DIR
        # > --with-expat=yes        use expat
        # > --with-expatincludedir=DIR
        # > --with-expatlibdir=DIR  use EXPAT libraries from DIR
        # > --with-devil=yes        DevIL plugin
        # > --with-devilincludedir=DIR
        # > --with-devillibdir=DIR  use DevIL libraries from DIR
        # > --with-zincludedir=DIR  use Z includes from DIR
        # > --with-zlibdir=DIR      use Z libraries from DIR
        # > --with-webp=yes         webp library
        # > --with-poppler=yes      poppler library
        # > --with-rsvg=yes         rsvg library
        # > --with-ghostscript=yes  ghostscript library
        # > --with-visio=yes        visio library
        # > --with-pangocairo=yes   pangocairo library
        # > --with-lasi=yes         lasi library
        # > --with-freetype2=yes    freetype2 library
        # > --with-fontconfig=yes   use fontconfig library
        # > --with-gdk=yes          gdklibrary
        # > --with-gdk-pixbuf=yes   gdk-pixbuf library
        # > --with-gtk=yes          gtk+ library
        # > --with-gtkgl=yes        gtkgl library
        # > --with-gtkglext=yes     gtkglext library
        # > --with-gts=yes          gts library
        # > --with-ann=yes          ANN library
        # > --with-glade=yes        glade library
        # > --with-qt=yes           Qt features
        # > --with-quartz=no        Quartz framework (Mac OS X)
        # > --with-platformsdkincludedir=DIR
        # > --with-platformsdklibdir=DIR
        # > --with-gdiplus=no       GDI+ framework (Windows)
        # > --with-libgd=yes        use gd library
        # > --with-gdincludedir=DIR use GD includes from DIR
        # > --with-gdlibdir=DIR     use GD libraries from DIR
        # > --with-glut=yes         GLUT library
        # > --with-glutincludedir=DIR
        # > --with-glutlibdir=DIR   use GLUT libraries from DIR
        # > --with-sfdp=yes         sfdp layout engine
        # > --with-smyrna=yes       SMYRNA large graph viewer
        # > --with-ortho=yes        ORTHO features in neato layout engine
        # > --with-digcola=yes      DIGCOLA features in neato layout engine
        # > --with-ipsepcola=yes    IPSEPCOLA features in neato layout engine
        "--prefix=${dict[prefix]}"
        '--disable-debug'
        '--disable-man-pdfs'
        '--enable-shared'
        '--enable-static'
    )
    ./configure "${conf_args[@]}"
    "${app[make]}" --jobs="${dict[jobs]}"
    "${app[make]}" install
    return 0
}

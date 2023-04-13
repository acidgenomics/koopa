#!/usr/bin/env bash

main() {
    # """
    # Uninstall R framework binary.
    # @note Updated 2023-04-13.
    # """
    local -a rm_files
    [[ -d '/Library/Frameworks/R.framework' ]] || return 0
    if koopa_is_aarch64
    then
        rm_files+=('/opt/R')
    else
        rm_files+=(
            '/Applications/R.app'
            '/Library/Frameworks/R.framework'
            '/usr/local/bin/R'
            '/usr/local/bin/Rscript'
            '/usr/local/bin/info'
            '/usr/local/bin/install-info'
            '/usr/local/bin/makeinfo'
            '/usr/local/bin/pdftexi2dvi'
            '/usr/local/bin/pod2texi'
            '/usr/local/bin/sqlite3_analyzer'
            '/usr/local/bin/tclsh8.6'
            '/usr/local/bin/texi2any'
            '/usr/local/bin/texi2dvi'
            '/usr/local/bin/texi2pdf'
            '/usr/local/bin/texindex'
            '/usr/local/bin/wish8.6'
            '/usr/local/include/fakemysql.h'
            '/usr/local/include/fakepq.h'
            '/usr/local/include/fakesql.h'
            '/usr/local/include/itcl.h'
            '/usr/local/include/itcl2TclOO.h'
            '/usr/local/include/itclDecls.h'
            '/usr/local/include/itclInt.h'
            '/usr/local/include/itclIntDecls.h'
            '/usr/local/include/itclMigrate2TclCore.h'
            '/usr/local/include/itclTclIntStubsFcn.h'
            '/usr/local/include/mysqlStubs.h'
            '/usr/local/include/odbcStubs.h'
            '/usr/local/include/pqStubs.h'
            '/usr/local/include/tcl.h'
            '/usr/local/include/tclDecls.h'
            '/usr/local/include/tclOO.h'
            '/usr/local/include/tclOODecls.h'
            '/usr/local/include/tclPlatDecls.h'
            '/usr/local/include/tclThread.h'
            '/usr/local/include/tclTomMath.h'
            '/usr/local/include/tclTomMathDecls.h'
            '/usr/local/include/tdbc.h'
            '/usr/local/include/tdbcDecls.h'
            '/usr/local/include/tdbcInt.h'
            '/usr/local/include/tk.h'
            '/usr/local/include/tkDecls.h'
            '/usr/local/include/tkPlatDecls.h'
            '/usr/local/lib/Tktable2.10'
            '/usr/local/lib/itcl4.0.5'
            '/usr/local/lib/libtcl8.6.dylib'
            '/usr/local/lib/libtclstub8.6.a'
            '/usr/local/lib/libtk8.6.dylib'
            '/usr/local/lib/libtkstub8.6.a'
            '/usr/local/lib/pkgconfig/tcl.pc'
            '/usr/local/lib/pkgconfig/tk.pc'
            '/usr/local/lib/sqlite3.13.0'
            '/usr/local/lib/tcl8'
            '/usr/local/lib/tcl8.6'
            '/usr/local/lib/tclConfig.sh'
            '/usr/local/lib/tclooConfig.sh'
            '/usr/local/lib/tdbc1.0.4'
            '/usr/local/lib/tdbcmysql1.0.4'
            '/usr/local/lib/tdbcodbc1.0.4'
            '/usr/local/lib/tdbcpostgres1.0.4'
            '/usr/local/lib/thread2.8.0'
            '/usr/local/lib/tk8.6'
            '/usr/local/lib/tkConfig.sh'
            '/usr/local/man/man1/tclsh.1'
            '/usr/local/man/man1/wish.1'
            '/usr/local/man/man3/attemptckalloc.3'
            '/usr/local/man/man3/attemptckrealloc.3'
            '/usr/local/man/man3/ckalloc.3'
            '/usr/local/man/man3/ckfree.3'
            '/usr/local/man/man3/ckrealloc.3'
            '/usr/local/man/mann'
            '/usr/local/share/info/dir'
            '/usr/local/share/info/info-stnd.info'
            '/usr/local/share/info/texinfo.info'
            '/usr/local/share/info/texinfo.info-1'
            '/usr/local/share/info/texinfo.info-2'
            '/usr/local/share/info/texinfo.info-3'
        )
        koopa_rm --sudo \
            '/usr/local/man/man3/TCL_'* \
            '/usr/local/man/man3/Tcl_'* \
            '/usr/local/man/man3/Tk_'*
    fi
    koopa_rm --sudo "${rm_files[@]}"
    return 0
}

#!/usr/bin/env bash

main() {
    # """
    # Uninstall R framework binary.
    # @note Updated 2022-03-23.
    # """
    local -a files
    files=(
        '/Applications/R.app'
        '/Library/Frameworks/R.framework'
        '/usr/local/bin/R'
        '/usr/local/bin/Rscript'
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
        '/usr/local/lib/libtcl8.6.dylib'
        '/usr/local/lib/libtclstub8.6.a'
        '/usr/local/lib/libtk8.6.dylib'
        '/usr/local/lib/libtkstub8.6.a'
        '/usr/local/lib/pkgconfig/tcl.pc'
        '/usr/local/lib/pkgconfig/tk.pc'
    )
    koopa_rm --sudo "${files[@]}"
    return 0
}

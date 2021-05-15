#!/usr/bin/env bash

koopa::macos_install_r_data_table() { # {{{1
    # """
    # Install R data.table package on macOS with OpenMP for parallel thread
    # support.
    # @note Updated 2021-05-03.
    #
    # Configuration via '<pkg>/src/Makevars' doesn't work, so using user R
    # Makevars file as an override here instead.
    #
    # @seealso
    # - https://github.com/Rdatatable/data.table/wiki/Installation
    # """
    local c_prefix makevars_file name sdk_prefix tmp_dir
    name='data.table'
    c_prefix='/usr/local/gfortran'
    sdk_prefix='/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk'
    koopa::assert_is_dir "$c_prefix" "$sdk_prefix"
    makevars_file="${HOME}/.R/Makevars"
    if [[ -f "$makevars_file" ]]
    then
        koopa::stop "Makevars already defined at '${makevars_file}'."
    fi
    koopa::install_start "$name"
    cat << END > "$makevars_file"
C_LOC=/usr/local/gfortran
SDK_LOC=/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk
CC=\$(C_LOC)/bin/gcc -fopenmp
CXX=\$(C_LOC)/bin/g++ -fopenmp
CXX11=\$(C_LOC)/bin/g++ -fopenmp
CFLAGS=-g -O3 -Wall -pedantic -std=gnu99 -mtune=native -pipe
CPPFLAGS=-I\$(C_LOC)/include -I\$(SDK_LOC)/usr/include
CXXFLAGS=-g -O3 -Wall -pedantic -std=c++11 -mtune=native -pipe
CXX11FLAGS=-g -O3 -Wall -pedantic -std=c++11 -mtune=native -pipe
LDFLAGS=-L\$(C_LOC)/lib -Wl,-rpath,\$(C_LOC)/lib
END
    koopa::mkdir "$(dirname "$makevars_file")"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        koopa::download_cran_latest "$name"
        tar -xzvf "${name}_"*'.tar.gz'
        koopa::cd "$name" || return 1
        cat "$makevars_file"
        R CMD INSTALL .
    )
    koopa::rm "$makevars_file"
    koopa::install_success "$name"
    return 0
}

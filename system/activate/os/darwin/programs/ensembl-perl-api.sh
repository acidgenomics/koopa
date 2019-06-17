#!/bin/sh

# Ensembl Perl API
# Modified 2019-06-17.

# See also:
# - https://useast.ensembl.org/info/docs/api/api_installation.html
# - https://useast.ensembl.org/info/docs/api/api_git.html
# - https://github.com/Ensembl/ensembl-git-tools/blob/master/README.md

# git clone -b release-1-6-924 --depth 1 https://github.com/bioperl/bioperl-live.git

ensembl_dir="${HOME}/.ensembl"

# Early return if Ensembl git directory is missing.
[ ! -d "$ensembl_dir" ] && return 0

add_to_path_start "${ensembl_dir}/ensembl-git-tools/bin"

# perlbrew switch perl-5.26

PERL5LIB="${PERL5LIB}:${ensembl_dir}/bioperl-1.6.924"
PERL5LIB="${PERL5LIB}:${ensembl_dir}/ensembl/modules"
PERL5LIB="${PERL5LIB}:${ensembl_dir}/ensembl-compara/modules"
PERL5LIB="${PERL5LIB}:${ensembl_dir}/ensembl-variation/modules"
PERL5LIB="${PERL5LIB}:${ensembl_dir}/ensembl-funcgen/modules"
export PERL5LIB

unset -v ensembl_dir

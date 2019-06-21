#!/bin/sh

# Ensembl Perl API
# Modified 2019-06-17.

ensembl_dir="${KOOPA_BUILD_PREFIX}/ensembl"

# Early return if Ensembl git directory is missing.
[ ! -d "$ensembl_dir" ] &&
    unset -v ensembl_dir &&
    return 0

_koopa_add_to_path_start "${ensembl_dir}/ensembl-git-tools/bin"

# perlbrew switch perl-5.26

PERL5LIB="${PERL5LIB}:${ensembl_dir}/bioperl-1.6.924"
PERL5LIB="${PERL5LIB}:${ensembl_dir}/ensembl/modules"
PERL5LIB="${PERL5LIB}:${ensembl_dir}/ensembl-compara/modules"
PERL5LIB="${PERL5LIB}:${ensembl_dir}/ensembl-variation/modules"
PERL5LIB="${PERL5LIB}:${ensembl_dir}/ensembl-funcgen/modules"
export PERL5LIB

unset -v ensembl_dir

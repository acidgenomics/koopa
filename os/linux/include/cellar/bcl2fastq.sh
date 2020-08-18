#!/usr/bin/env bash
# shellcheck disable=SC2154

# e.g. 2.20.0.422 to 2-20-0.
version2="$(koopa::sub '\.[0-9]+$' '' "$version")"
version2="$(koopa::kebab_case "$version2")"
file="bcl2fastq2-v${version2}-tar.zip"
url_prefix='http://seq.cloud/install/bcl2fastq'
url="${url_prefix}/source/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::extract "bcl2fastq2-v${version}-Source.tar.gz"
koopa::cd bcl2fastq
koopa::mkdir bcl2fastq-build
koopa::cd bcl2fastq-build
# Fix for missing '/usr/include/x86_64-linux-gnu/sys/stat.h'.
export C_INCLUDE_PATH='/usr/include/x86_64-linux-gnu'
../src/configure --prefix="$prefix"
make --jobs="$jobs"
make install
# For some reason bcl2fastq creates an empty test directory.
koopa::rm "${prefix}/bin/test"

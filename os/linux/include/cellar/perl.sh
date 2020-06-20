#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# https://www.cpan.org/src/
# https://metacpan.org/pod/distribution/perl/INSTALL
# https://perlmaven.com/how-to-build-perl-from-source-code
#
# Using 'PERL_MM_USE_DEFAULT' below to avoid interactive prompt to configure
# CPAN.pm for the first time.
#
# Otherwise you'll hit this interactive prompt:
#
# CPAN.pm requires configuration, but most of it can be done automatically.
# If you answer 'no' below, you will enter an interactive dialog for each
# configuration option instead.
#
# Would you like to configure as much as possible automatically? [yes]
#
# See also:
# - https://metacpan.org/pod/CPAN::FirstTime
# - https://www.reddit.com/r/perl/comments/1xed7b/
#       how_can_i_configure_cpan_as_much_as_possible/
#
#
# Might want to update CPAN.pm:
# New CPAN.pm version (v2.27) available.
# [Currently running version is v2.22]
# You might want to try
#   install CPAN
#   reload cpan
# to both upgrade CPAN.pm and run the new version without leaving
# the current session.
# """

file="${name}-${version}.tar.gz"
url="https://www.cpan.org/src/5.0/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
./Configure -des -Dprefix="$prefix"
make --jobs="$jobs"
# The installer will warn when you skip this step.
# > make test
make install

export PERL_MM_USE_DEFAULT=1

_koopa_h2 "Installing CPAN Minus."
"${prefix}/bin/cpan" -i "App::cpanminus"

modules=(
    'File::Rename'
)
for module in "${modules[@]}"
do
    _koopa_h2 "Installing '${module}' module."
    "${prefix}/bin/cpanm" "$module"
done

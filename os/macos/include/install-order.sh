#!/usr/bin/env bash

# Last updated 2022-04-10.

# Recipes that we need to install:
# - libtasn1
# - lapack
# - openblas

# First configure the shell to load koopa.
koopa install dotfiles

# We need to install AWS CLI to push builds to S3 bucket.
koopa install aws-cli
koopa system push-app-build 'aws-cli' '2.5.4'

koopa install pkg-config --push --reinstall
koopa install tar --push --reinstall
koopa install xz --push --reinstall
koopa install gettext --push --reinstall

# This is currently problematic on macOS.
# > koopa install attr --push --reinstall

koopa install coreutils --push --reinstall
koopa install findutils --push --reinstall
koopa install autoconf --push --reinstall
koopa install automake --push --reinstall
koopa install make --push --reinstall
koopa install openssl --push --reinstall
koopa install cmake --push --reinstall
koopa install grep --push --reinstall
koopa install curl --push --reinstall

# Ensure we switch back to system shell before installing.
koopa install bash --push --reinstall

koopa install python --push --reinstall
koopa install git --push --reinstall
koopa install rsync --push --reinstall

# TODO list:
ncurses
tmux
apr
apr-util
cpufetch
fish
fltk
gawk
gdal
geos

gmp
gnupg
go
go-packages
groff
haskell-stack
hdf5
icu4c
imagemagick
jpeg
julia
julia-packages
lesspipe
libevent
libidn
libtiff
libtool
libxml2
libzip
lua
luarocks
meson
neofetch
neovim
nettle
nim
nim-packages
ninja
node
node-packages
pcre2
perl
perl-packages
proj
rsync
ruby
rust
scons
sed
serf
sqlite
subversion
tree
udunits
vim
wget
xz
zlib
zsh
zstd

koopa install chemacs --push --reinstall

python-packages
ruby-packages
rust-packages

# Don't push these:
conda
anaconda
r-packages

# > gcc
# > gnutls
# > openssh

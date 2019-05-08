#!/usr/bin/env bash
set -Eeuxo pipefail

# Install TeX packages using tlmgr.

echo "Installing TeX packages recommended for RStudio."
echo "sudo is required for this script."
sudo -v

sudo tlmgr update --self

packages=(collection-fontsrecommended  # priority
          collection-latexrecommended  # priority
          bera  # beramono
          caption
          changepage
          csvsimple
          enumitem
          etoolbox
          fancyhdr
          footmisc
          framed
          geometry
          hyperref
          inconsolata
          marginfix
          mathtools
          natbib
          nowidow
          parnotes
          parskip
          placeins
          preprint  # authblk
          sectsty
          soul
          titlesec
          titling
          xstring)

for package in ${packages[@]}
do
    sudo tlmgr install "$package"
done

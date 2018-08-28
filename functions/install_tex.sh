# https://www.ctan.org/
brew cask install basictex
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
for package in ${packages[@]}; do
    sudo tlmgr install "$package"
done

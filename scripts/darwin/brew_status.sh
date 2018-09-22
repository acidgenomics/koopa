echo "Homebrew leaves"
brew leaves

echo "Homebrew versions"
brew list --versions

echo "Homebrew dependencies"
brew deps --installed --tree

brew outdated
brew cask outdated
brew missing

echo "Homebrew doctor"
brew doctor

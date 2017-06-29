command -v git >/dev/null 2>&1 || { echo >&2 "git missing"; exit 1; }

git clone https://github.com/Linuxbrew/brew.git ~/.linuxbrew

brew tap homebrew/science

brew install fastqc
brew install git
brew install kallisto
brew install python
brew install python3
brew install R
brew install rna-star
brew install salmon
brew install sratoolkit

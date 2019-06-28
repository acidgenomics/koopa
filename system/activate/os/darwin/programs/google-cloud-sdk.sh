#!/bin/sh

# Google Cloud SDK
# Modified 2019-06-17.

# Install using Homebrew Cask:
# > brew cask install google-cloud-sdk

dir="${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
if [ -d "$dir" ]
then
    . "${dir}/path.bash.inc"
    . "${dir}/completion.bash.inc"
fi
unset -v dir

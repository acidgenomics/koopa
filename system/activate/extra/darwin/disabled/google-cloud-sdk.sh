#!/bin/sh
# shellcheck disable=SC1090

# Google Cloud SDK
# Install using Homebrew Cask:
# brew cask install google-cloud-sdk

dir="${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
if [ -d "$dir" ]
then
    . "${dir}/path.bash.inc"
    . "${dir}/completion.bash.inc"
fi
unset -v dir

#!/bin/sh

## Google Cloud SDK
## Updated 2019-07-09.

## Install using Homebrew Cask:
## > brew cask install google-cloud-sdk

dir="${HOMEBREW_PREFIX}/Caskroom/google-cloud-sdk/latest/google-cloud-sdk"
if [ -d "$dir" ]
then
    ## shellcheck source=/dev/null
    . "${dir}/path.bash.inc"
    ## shellcheck source=/dev/null
    . "${dir}/completion.bash.inc"
fi
unset -v dir

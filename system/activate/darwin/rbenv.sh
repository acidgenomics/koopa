#!/bin/sh

# Ruby (rbenv)
# https://github.com/rbenv/rbenv

# export PATH="${HOME}/.rbenv/shims:${PATH}"
# eval "$(rbenv init -)"
quiet_which rbenv && add_to_path_start "$(rbenv root)/shims"

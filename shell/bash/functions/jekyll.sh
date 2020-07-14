#!/usr/bin/env bash

koopa::jekyll_serve() {
    # """
    # Render Jekyll website.
    # Updated 2020-07-08.
    # """
    local dir
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed bundle
    dir="${1:-.}"
    (
        koopa::cd "$dir"
        bundle update --bundler
        bundle install
        bundle exec jekyll serve
    )
    return 0
}


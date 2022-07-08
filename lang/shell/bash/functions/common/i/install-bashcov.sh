#!/usr/bin/env bash

# FIXME This isn't installing with isolation correctly.
# shcov (Gem::GemNotFoundException)
# 	from /opt/koopa/app/ruby/3.1.2p20/lib/ruby/3.1.0/rubygems.rb:284:in `activate_bin_path'
# 	from /opt/koopa/bin/bashcov:25:in `<main>'
# FIXME Do we need to use bundle to accomplish this?

koopa_install_bashcov() {
    koopa_install_app \
        --installer='ruby-package' \
        --link-in-bin='bin/bashcov' \
        --name='bashcov' \
        "$@"
}

#!/usr/bin/env bash

# NOTE The json-sort-order plugin isn't compatible with prettier 3 yet.
# - https://github.com/Gudahtt/prettier-plugin-sort-json/issues/119
# - https://www.npmjs.com/package/prettier

main() {
    koopa_install_app_subshell \
        --installer='node-package' \
        --name='prettier' \
        -D 'prettier-plugin-sort-json@2.0.0'
}

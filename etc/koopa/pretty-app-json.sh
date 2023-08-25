#!/bin/sh

# prettier v3 currently isn't detecting global plugins correctly.
# https://github.com/prettier/prettier/issues/15141

set -o errexit
set -o nounset

main() {
    plugin="${KOOPA_PREFIX:?}/opt/prettier/lib/node_modules/\
prettier-plugin-sort-json/dist/index.js"
    prettier \
        --plugin="$plugin" \
        --json-recursive-sort \
        app.json > app.json.tmp
    rm app.json
    mv app.json.tmp app.json
    return 0
}

main "$@"

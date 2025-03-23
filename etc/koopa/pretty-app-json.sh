#!/usr/bin/env bash

# NOTE prettier v3 currently isn't detecting global plugins correctly.
# https://github.com/prettier/prettier/issues/15141

# shellcheck source=/dev/null
source "$(koopa header bash)"

main() {
    local -A app dict
    app['prettier']="$(koopa_locate_prettier)"
    koopa_assert_is_executable "${app[@]}"
    dict['plugin']="${KOOPA_PREFIX:?}/opt/prettier/lib/node_modules/\
prettier-plugin-sort-json/dist/index.js"
    koopa_assert_is_file "${dict['plugin']}"
    "${app['prettier']}" \
        --plugin="${dict['plugin']}" \
        --json-recursive-sort \
        'app.json' > 'app.json.tmp'
    rm 'app.json'
    mv 'app.json.tmp' 'app.json'
    return 0
}

main "$@"

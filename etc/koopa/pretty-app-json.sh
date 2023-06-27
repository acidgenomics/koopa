#!/bin/sh

set -o errexit
set -o nounset

main() {
    prettier --json-recursive-sort app.json > app.json.tmp
    rm app.json
    mv app.json.tmp app.json
    return 0
}

main "$@"

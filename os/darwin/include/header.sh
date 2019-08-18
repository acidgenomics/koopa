#!/usr/bin/env bash
set -Eeu -o pipefail

# shellcheck source=/dev/null
source "$(_koopa_header bash)"

_koopa_assert_is_darwin

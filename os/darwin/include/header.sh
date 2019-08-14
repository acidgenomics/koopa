#!/usr/bin/env bash
set -Eeu -o pipefail

# shellcheck source=/dev/null
source "$(koopa header bash)"

_koopa_assert_is_darwin

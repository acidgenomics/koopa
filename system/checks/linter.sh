#!/usr/bin/env bash
set -Eeu -o pipefail

# Linter checks.
# Updated 2019-10-07.

KOOPA_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." \
    >/dev/null 2>&1 && pwd -P)"
export KOOPA_HOME

linter_dir="${KOOPA_HOME}/system/linter"
for file in "${linter_dir}/"*".sh"
do
    if [[ -n "${CI:-}" ]]
    then
        case "$(basename "$file")" in
            python-*|r-*)
                ;;
            *)
                # shellcheck source=/dev/null
                [ -f "$file" ] && "$file"
                ;;
        esac
    else
        # shellcheck source=/dev/null
        [ -f "$file" ] && "$file"
    fi
done

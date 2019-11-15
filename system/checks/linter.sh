#!/usr/bin/env bash
set -Eeu -o pipefail

# Linter checks.
# Updated 2019-10-26.

KOOPA_PREFIX="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../.." \
    >/dev/null 2>&1 && pwd -P)"
export KOOPA_PREFIX

linter_dir="${KOOPA_PREFIX}/system/linter"
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

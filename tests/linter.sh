#!/usr/bin/env bash

# """
# Check that scripts do not contain lints.
# Updated 2020-02-01.
# """

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" \
    >/dev/null 2>&1 && pwd -P)"
KOOPA_PREFIX="$(cd "${script_dir}/.." >/dev/null 2>&1 && pwd -P)"
export KOOPA_PREFIX
# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

_koopa_h1 "Running linter checks."

# Check that linter config files are linked correctly.
# This step can error if dotfiles submodule hasn't cloned.
_koopa_assert_is_symlink "${KOOPA_PREFIX}/."{lintr,pylintrc}

linter_dir="${script_dir}/linter"
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

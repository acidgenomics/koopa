#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../debian/include/header.sh"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/functions/os/ubuntu.sh"

koopa::assert_is_ubuntu

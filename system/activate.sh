#!/bin/sh
# shellcheck disable=SC1090
# shellcheck disable=SC2236

# Activate koopa in the current shell.

. "${KOOPA_SYSTEM_DIR}/activate/functions.sh"
. "${KOOPA_SYSTEM_DIR}/activate/uname.sh"
. "${KOOPA_SYSTEM_DIR}/activate/bash-version.sh"
. "${KOOPA_SYSTEM_DIR}/activate/python-version.sh"
. "${KOOPA_SYSTEM_DIR}/activate/path.sh"
. "${KOOPA_SYSTEM_DIR}/activate/exports.sh"
. "${KOOPA_SYSTEM_DIR}/activate/aliases.sh"
. "${KOOPA_SYSTEM_DIR}/activate/genomes.sh"
. "${KOOPA_SYSTEM_DIR}/activate/cpu-count.sh"
. "${KOOPA_SYSTEM_DIR}/activate/user-bin.sh"
. "${KOOPA_SYSTEM_DIR}/activate/bcbio.sh"
. "${KOOPA_SYSTEM_DIR}/activate/conda.sh"
. "${KOOPA_SYSTEM_DIR}/activate/ssh-key.sh"

if [ ! -z "$MACOS" ]
then
    . "${KOOPA_SYSTEM_DIR}/activate/darwin/exports.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/darwin/aliases.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/darwin/grc-colors.sh"
    . "${KOOPA_SYSTEM_DIR}/activate/darwin/rbenv.sh"
    # homebrew.sh
    # homebrew-python.sh
    # perlbrew.sh
    # ensembl-perl-api.sh
    # google-cloud-sdk.sh
fi

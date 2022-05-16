#!/usr/bin/env bash

# FIXME Need to add recipe support for this, or switch to conda.

koopa_locate_fasterq_dump() {
    koopa_locate_app \
        --app-name='fasterq-dump' \
        --opt-name='sratoolkit'
}

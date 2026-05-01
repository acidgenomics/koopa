#!/usr/bin/env bash

_koopa_locate_df() {
    _koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdf' \
        --system-bin-name='df' \
        "$@"
}

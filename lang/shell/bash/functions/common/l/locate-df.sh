#!/usr/bin/env bash

koopa_locate_df() {
    koopa_locate_app \
        --app-name='coreutils' \
        --bin-name='gdf' \
        "$@"
}

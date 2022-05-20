#!/usr/bin/env bash

# FIXME Return the platform and architecture here automatically.
# FIXME Also consider adding support for easy return of S3 bucket path.

koopa_koopa_app_binary_url() {
    # """
    # Koopa app binary URL.
    # @note Updated 2022-04-08.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print "$(koopa_koopa_url)/app"
}

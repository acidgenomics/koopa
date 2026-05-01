#!/usr/bin/env zsh

_koopa_is_root() {
    [[ "$(_koopa_user_id)" -eq 0 ]]
}

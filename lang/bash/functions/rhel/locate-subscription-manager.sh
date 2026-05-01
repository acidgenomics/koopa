#!/usr/bin/env bash

_koopa_rhel_locate_subscription_manager() {
    _koopa_locate_app '/usr/sbin/subscription-manager' "$@"
}

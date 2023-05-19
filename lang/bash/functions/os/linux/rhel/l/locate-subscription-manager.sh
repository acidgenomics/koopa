#!/usr/bin/env bash

koopa_rhel_locate_subscription_manager() {
    koopa_locate_app '/usr/sbin/subscription-manager' "$@"
}

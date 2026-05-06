#!/usr/bin/env bash

_koopa_is_arm64() {
    case "$(uname -m)" in
        'aarch64' | 'arm64') return 0 ;;
        *) return 1 ;;
    esac
}

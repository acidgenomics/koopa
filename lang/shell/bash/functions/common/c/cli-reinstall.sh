#!/usr/bin/env bash

koopa_cli_reinstall() {
    case "${1:-}" in
        '--all-revdeps')
            shift 1
            koopa_reinstall_all_revdeps "$@"
            return 0
            ;;
        '--only-revdeps')
            shift 1
            koopa_reinstall_all_revdeps "$@"
            return 0
            ;;
    esac
    koopa_cli_install --reinstall "$@"
}

#!/usr/bin/env bash

koopa_cli_app() {
    # """
    # Parse user input to 'koopa app'.
    # @note Updated 2022-04-19.
    #
    # @examples
    # > koopa_cli_app 'aws' 'batch' 'fetch-and-run'
    # """
    local key
    case "${1:-}" in
        # Help documentation ---------------------------------------------------
        '--help' | \
        '-h')
            koopa_help "$(koopa_man_prefix)/man1/app.1"
            ;;
        # Cross platform -------------------------------------------------------
        'aws')
            case "${2:-}" in
                'batch')
                    case "${3:-}" in
                        'fetch-and-run' | \
                        'list-jobs')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'ec2')
                    case "${3:-}" in
                        'instance-id' | \
                        'suspend' | \
                        'terminate')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                's3')
                    case "${3:-}" in
                        'find' | \
                        'list-large-files' | \
                        'ls' | \
                        'mv-to-parent' | \
                        'sync')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'bioconda')
            case "${2:-}" in
                'autobump-recipe')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'bowtie2')
            case "${2:-}" in
                'align' | \
                'index')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'conda')
            case "${2:-}" in
                'create-env' | \
                'remove-env')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'docker')
            case "${2:-}" in
                'build' | \
                'build-all-images' | \
                'build-all-tags' | \
                'prune-all-images' | \
                'prune-all-stale-tags' | \
                'prune-old-images' | \
                'prune-stale-tags' | \
                'push' | \
                'remove' | \
                'run' | \
                'tag')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'ftp')
            case "${2:-}" in
                'mirror')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'git')
            case "${2:-}" in
                'checkout-recursive' | \
                'pull' | \
                'pull-recursive' | \
                'push-recursive' | \
                'push-submodules' | \
                'rename-master-to-main' | \
                'reset' | \
                'reset-fork-to-upstream' | \
                'rm-submodule' | \
                'rm-untracked' | \
                'status-recursive')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'gpg')
            case "${2:-}" in
                'prompt' | \
                'reload' | \
                'restart')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'jekyll')
            case "${2:-}" in
                'serve')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'kallisto' | \
        'salmon')
            case "${2:-}" in
                'index')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                'quant')
                    case "${3:-}" in
                        'paired-end' | \
                        'single-end')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'md5sum')
            case "${2:-}" in
                'check-to-new-md5-file')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'rnaeditingindexer')
            key="${1:?}"
            shift 1
            ;;
        'sra')
            case "${2:-}" in
                'download-accession-list' | \
                'download-run-info-table' | \
                'fastq-dump' | \
                'prefetch')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'ssh')
            case "${2:-}" in
                'generate-key')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'star')
            case "${2:-}" in
                'align')
                    case "${3:-}" in
                        'paired-end' | \
                        'single-end')
                            key="${1:?}-${2:?}-${3:?}"
                            shift 3
                            ;;
                        *)
                            koopa_cli_invalid_arg "$@"
                        ;;
                    esac
                    ;;
                'index')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        'wget')
            case "${2:-}" in
                'recursive')
                    key="${1:?}-${2:?}"
                    shift 2
                    ;;
                *)
                    koopa_cli_invalid_arg "$@"
                    ;;
            esac
            ;;
        # Invalid --------------------------------------------------------------
        *)
            koopa_cli_invalid_arg "$@"
            ;;
    esac
    koopa_print "$key" "$@"
    return 0
}

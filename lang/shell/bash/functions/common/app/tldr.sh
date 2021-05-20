#!/usr/bin/env bash

koopa::tldr() { # {{{1
    # """
    # tldr
    # @note Updated 2020-07-03.
    #
    # Modified version of tldr client by Ray Lee.
    #
    # There are pages with hypens in them, such as 'git-tag'. This converts
    # 'tldr git tag' to the hyphenated version.
    #
    # @seealso
    # - http://github.com/raylee/tldr
    # - https://github.com/tldr-pages/tldr/tree/master/pages
    # """
    local cmd file
    cmd="${1:-}"
    [[ -z "$cmd" ]] && cmd='--list'
    case "$cmd" in
        -c|-u|--cache|--update)
            koopa::tldr_cache
            return 0
            ;;
        -l|--list)
            koopa::tldr_list_pages
            return 0
            ;;
    esac
    cmd="$(koopa::gsub ' ' '-' "$*")"
    koopa::tldr_download_cache
    koopa::tldr_update_index
    file="$(koopa::tldr_file "$cmd")"
    koopa::tldr_display "$file"
    return 0
}

koopa::tldr_display() { # {{{1
    # """
    # Display rendered tldr page.
    # @note Updated 2020-07-03.
    # """
    local file italic_end italic_start line lines
    koopa::assert_has_args_eq "$#" 1
    file="${1:?}"
    koopa::assert_is_file "$file"
    readarray -t lines < "$file"
    # Reformat style tags, making text italic.
    italic_start="$(printf '\033[3m')"
    italic_end="$(printf '\033[23m')"
    readarray -t lines <<< "$( \
        koopa::print "${lines[@]}" \
            | sed "s/{{/${italic_start}/g;s/}}/${italic_end}/g" \
    )"
    code() { # {{{1
        # shellcheck disable=SC2016
        koopa::print_blue_bold "$( \
            koopa::print "${1:?}" \
                | sed 's/\`\([^\`]*\)\`/  \1/g' \
        )"
    }
    heading() { # {{{1
        koopa::print_magenta_bold "${*#??}"
    }
    list_item() { # {{{1
        koopa::print "${1:-}"
    }
    quotation() { # {{{1
        koopa::print "${*#??}"
    }
    text() { # {{{1
        koopa::print "${1:-}"
    }
    (
        for line in "${lines[@]}"
        do
            case "$line" in
                \#*)
                    heading "$line"
                    ;;
                \>*)
                    quotation "$line"
                    ;;
                -*)
                    list_item "$line"
                    ;;
                \`*)
                    code "$line"
                    ;;
                *)
                    text "$line"
                    ;;
            esac
        done
    ) | koopa::pager
    return 0
}

koopa::tldr_download_cache() { # {{{1
    # """
    # Cache a local copy of the tldr-pages repo.
    # @note Updated 2020-12-31.
    # """
    local file prefix tmp_dir url
    koopa::assert_has_no_args "$#"
    prefix="$(koopa::tldr_prefix)"
    [[ -d "$prefix" ]] && return 0
    koopa::alert 'Caching tldr pages from GitHub.'
    koopa::mkdir "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        url='https://github.com/tldr-pages/tldr/tarball/master'
        file='master.tar.gz'
        koopa::download "$url" "$file"
        koopa::extract "$file"
        koopa::rsync --archive \
            'tldr-pages-tldr-'*'/pages/' \
            "${prefix}/"
    )
    koopa::rm "$tmp_dir"
    return 0
}

koopa::tldr_file() { # {{{1
    # """
    # Get the tldr file path, using 'index.json' and platform key.
    # @note Updated 2020-08-13.
    # """
    local cmd desc file index_file platform prefix subdir
    koopa::assert_has_args_eq "$#" 1
    cmd="${1:?}"
    platform="$(koopa::tldr_platform)"
    prefix="$(koopa::tldr_prefix)"
    index_file="$(koopa::tldr_index_file)"
    koopa::assert_is_file "$index_file"
    # Parse the JSON file.
    desc="$( \
        tr '{' '\n' < "$index_file" \
        | grep "\"name\":\"${cmd}\"" \
    )"
    # Use the platform-specific version of the tldr first.
    if koopa::str_match "$desc" "$platform"
    then
        subdir="$platform"
    elif koopa::str_match "$desc" 'common'
    then
        subdir='common'
    else
        koopa::stop "Failed to locate tldr for '${cmd}'."
    fi
    file="${prefix}/${subdir}/${cmd}.md"
    koopa::assert_is_file "$file"
    koopa::print "$file"
    return 0
}

koopa::tldr_index_file() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::tldr_prefix)/index.json"
    return 0
}

koopa::tldr_list_pages() { # {{{1
    # """
    # List locally cached tldr pages.
    # @note Updated 2021-05-20.
    # """
    local cmd pages prefix
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed fzf
    prefix="$(koopa::tldr_prefix)"
    [[ ! -d "$prefix" ]] && koopa::mkdir "$prefix"
    readarray -t pages <<< "$( \
        koopa::find \
            --glob='*.md' \
            --prefix="$prefix" \
            --type='f' \
        | sort -u \
    )"
    cmd="$(koopa::basename_sans_ext "${pages[@]}" | fzf || true)"
    [[ -n "$cmd" ]] || return 0
    tldr "$cmd"
    return 0
}

koopa::tldr_platform() { # {{{1
    # """
    # Convert the local platorm name to tldr's version.
    # @note Updated 2020-07-03.
    # """
    local str
    koopa::assert_has_no_args "$#"
    case "$(uname -s)" in
        Darwin)
            str='osx'
            ;;
        Linux)
            str='linux'
            ;;
        SunOS)
            str='sunos'
            ;;
        CYGWIN*|MINGW32*|MSYS*)
            str='windows'
            ;;
        *)
            str='common'
            ;;
    esac
    koopa::print "$str"
    return 0
}

koopa::tldr_prefix() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::print "$(koopa::config_prefix)/tldr"
    return 0
}

koopa::tldr_update_index() { # {{{1
    # """
    # Update tldr index.
    # @note Updated 2020-07-03.
    # """
    local file url
    koopa::assert_has_no_args "$#"
    file="$(koopa::tldr_index_file)"
    koopa::is_recent "$file" && return 0
    url="https://raw.githubusercontent.com/tldr-pages/tldr-pages.github.io/\
master/assets/index.json"
    koopa::download "$url" "$file"
    return 0
}


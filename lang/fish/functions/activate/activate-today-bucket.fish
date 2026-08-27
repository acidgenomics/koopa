function _koopa_activate_today_bucket
    # Maintain dated 'today' symlinks.
    # @note Updated 2026-08-24.
    #
    # Maintains dated 'today' symlinks at both '~/today' and
    # '~/Documents/today'. These are two independent dated links (not an
    # alias pair), each repointed at '<bucket>/YYYY/MM/DD' on its own, so
    # either path stays current regardless of which bucket directory koopa
    # resolves.
    _koopa_is_interactive; or return 0
    set -l bucket_dir "$KOOPA_BUCKET"
    if test -n "$bucket_dir"
        test -d "$bucket_dir"; or return 0
    else if test -d "$HOME/bucket"
        set bucket_dir "$HOME/bucket"
    else if test -d "$HOME/Documents/bucket"
        set bucket_dir "$HOME/Documents/bucket"
    else
        return 0
    end
    # Resolve to the real directory, so the dated links never point through
    # a symlink alias (e.g. '~/bucket' -> 'Documents/bucket').
    set bucket_dir (realpath "$bucket_dir")
    set -l today_subdirs (date '+%Y/%m/%d')
    mkdir -p "$bucket_dir/$today_subdirs"
    for today_link in "$HOME/today" "$HOME/Documents/today"
        if test -d "$today_link"; and string match -q "*$today_subdirs*" (realpath "$today_link")
            continue
        end
        ln -fns "$bucket_dir/$today_subdirs" "$today_link"
    end
end

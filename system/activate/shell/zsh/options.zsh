#!/usr/bin/env zsh

# """
# ZSH shell options.
# Updated 2020-02-14.
#
# Debug with:
# - bindkey
# - setopt
#
# See also:
# - http://zsh.sourceforge.net/Doc/Release/Completion-System.html
# - http://zsh.sourceforge.net/Doc/Release/Options.html
# - http://zsh.sourceforge.net/Doc/Release/Options.html#index-MARKDIRS
# - http://zsh.sourceforge.net/Doc/Release/Options.html#index-NOMARKDIRS
# - http://zsh.sourceforge.net/Guide/zshguide06.html
# - https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/completion.zsh
# """

# Map key bindings to default editor.
# Note that Bash currently uses Emacs by default.
case "${EDITOR:-}" in
    emacs)
        bindkey -e
        ;;
    vi|vim)
        bindkey -v
        ;;
esac

# Fix the delete key.
bindkey "\e[3~" delete-char

setopt_array=(
    # auto_menu                 # completion
    # auto_name_dirs            # dirs
    # complete_aliases          # completion
    # extended_glob             # glob
    always_to_end               # completion
    append_history              # history
    auto_cd                     # dirs
    auto_pushd                  # dirs
    complete_in_word            # completion
    extended_history            # history
    hist_expire_dups_first      # history
    hist_ignore_dups            # history
    hist_ignore_space           # history
    hist_verify                 # history
    inc_append_history          # history
    interactive_comments        # misc
    long_list_jobs              # jobs
    pushd_ignore_dups           # dirs
    pushd_minus                 # dirs
    share_history               # history
)
setopt "${setopt_array[@]}"

unsetopt_array=(
    bang_hist
    flow_control
)
unsetopt "${unsetopt_array[@]}"

unset -v setopt_array unsetopt_array


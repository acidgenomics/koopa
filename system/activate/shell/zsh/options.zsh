#!/usr/bin/env zsh

# """
# ZSH shell options.
# Updated 2019-11-25.
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

setopt \
    alwaystoend \
    autocd \
    autopushd \
    completeinword \
    extendedhistory \
    histexpiredupsfirst \
    histignoredups \
    histignorespace \
    histverify \
    incappendhistory \
    interactivecomments \
    longlistjobs \
    noflowcontrol \
    pushdignoredups \
    pushdminus \
    sharehistory

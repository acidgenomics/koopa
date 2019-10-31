#!/usr/bin/env zsh

# ZSH shell options.
# Updated 2019-10-31.

# Debug with:
# - bindkey
# - setopt

# See also:
# - http://zsh.sourceforge.net/Doc/Release/Completion-System.html
# - http://zsh.sourceforge.net/Doc/Release/Options.html
# - https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/completion.zsh
# - http://zsh.sourceforge.net/Guide/zshguide06.html
# - http://zsh.sourceforge.net/Doc/Release/Options.html#index-MARKDIRS
# - http://zsh.sourceforge.net/Doc/Release/Options.html#index-NOMARKDIRS



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



setopt noautoparamkeys noautoparamslash nomarkdirs

# zstyle ':completion:*' accept-exact-dirs true
# zstyle ':completion:*' path-completion false
# zstyle ':completion:*' special-dirs false

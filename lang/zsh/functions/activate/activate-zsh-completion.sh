#!/usr/bin/env zsh

_koopa_activate_zsh_completion() {
    # """
    # Activate zsh-specific shell completions.
    # @note Updated 2026-05-03.
    #
    # Native compdef completions (_koopa, _chezmoi, _gh, etc.) are in
    # $KOOPA_PREFIX/share/zsh/site-functions/ which is on $fpath and picked
    # up automatically when compinit runs.
    #
    # Two apps ship non-compdef sourceable scripts that must be sourced
    # explicitly at shell startup:
    #
    # aws-cli: bin/aws_zsh_completer.sh calls autoload+bashcompinit itself
    #   and registers 'complete -C aws_completer aws'.  Sourced via the
    #   stable symlink we place in share/zsh/site-functions/.
    #
    # google-cloud-sdk: completion.zsh.inc uses its own argcomplete
    #   mechanism.  Sourced via the stable libexec/gcloud symlink the
    #   installer creates.
    # """
    local opt_prefix
    opt_prefix="$(_koopa_opt_prefix)"
    # aws-cli zsh completion.
    local aws_zsh
    aws_zsh="${opt_prefix}/aws-cli/share/zsh/site-functions/aws_zsh_completer.sh"
    [[ -f "$aws_zsh" ]] && source "$aws_zsh"
    # google-cloud-sdk zsh completion.
    local gcloud_zsh
    gcloud_zsh="${opt_prefix}/google-cloud-sdk/libexec/gcloud/completion.zsh.inc"
    [[ -f "$gcloud_zsh" ]] && source "$gcloud_zsh"
    return 0
}

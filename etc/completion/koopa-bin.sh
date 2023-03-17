#!/usr/bin/env bash

__kvar_words=('--prefix' '--recursive' '--strict')
complete -W "${__kvar_words[*]}" kebab-case snake-case
__kvar_words+=('--strict')
complete -W "${__kvar_words[*]}" camel-case
unset -v __kvar_words

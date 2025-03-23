#!/usr/bin/env bash

__kvar_words=('--prefix' '--recursive' '--strict')
complete -W "${__kvar_words[*]}" kebab-case snake-case
__kvar_words+=('--strict')
complete -W "${__kvar_words[*]}" camel-case
unset -v __kvar_words

# TODO Need to add support for these:
# - autopad-zeros
# - camel-case
# - clone
# - convert-sam-to-bam
# - convert-utf8-nfd-to-nfc
# - decompress
# - delete-broken-symlinks
# - delete-empty-dirs
# - delete-named-subdirs
# - detab
# - df2
# - download
# - download-cran-latest
# - download-github-latest
# - entab
# - eol-lf
# - extract
# - file-count
# - find-and-move-in-sequence
# - find-and-replace
# - find-broken-symlinks
# - find-empty-dirs
# - find-files-without-line-ending
# - find-large-dirs
# - find-large-files
# - ip-address
# - jekyll-serve
# - line-count
# - merge-pdf
# - move-files-in-batch
# - move-files-up-1-level
# - move-into-dated-dirs-by-filename
# - move-into-dated-dirs-by-timestamp
# - nfiletypes
# - rename-from-csv
# - rename-lowercase
# - rg-sort
# - rg-unique
# - snake-case
# - sort-lines
# - tar-multiple-dirs

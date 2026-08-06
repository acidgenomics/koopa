# koopa run

(koopa-run-autopad-zeros)=
## `run autopad-zeros directory`

Autopad zeros in numbered file names.

(koopa-run-clone)=
## `run clone source target`

Clone directory contents using rsync.

(koopa-run-convert-svg-to-png)=
## `run convert-svg-to-png files...`

Convert SVG files to PNG using macOS sips.

(koopa-run-convert-utf8-nfd-to-nfc)=
## `run convert-utf8-nfd-to-nfc paths...`

Convert UTF-8 NFD filenames to NFC.

(koopa-run-create-dmg)=
## `run create-dmg source-folder`

Create a DMG disk image from a source folder.

(koopa-run-delete-broken-symlinks)=
## `run delete-broken-symlinks dirs...`

Delete broken symlinks.

(koopa-run-delete-empty-dirs)=
## `run delete-empty-dirs dirs...`

Delete empty directories.

(koopa-run-delete-named-subdirs)=
## `run delete-named-subdirs directory name`

Delete subdirectories matching a name.

(koopa-run-detab)=
## `run detab files...`

Convert tabs to spaces.

(koopa-run-df2)=
## `run df2`

Wrapper around df with improved defaults.

(koopa-run-dns)=
## `run dns domain`

Print DNS records and nameserver provider for a domain.

- `--route53`

(koopa-run-dot-clean)=
## `run dot-clean directory`

Remove dot files and macOS cruft.

(koopa-run-download)=
## `run download url [output]`

Download a file from a URL.

(koopa-run-download-cran-latest)=
## `run download-cran-latest packages...`

Download latest CRAN package source.

(koopa-run-download-github-latest)=
## `run download-github-latest repo [--pattern glob]`

Download latest GitHub release asset.

- `--pattern`

(koopa-run-entab)=
## `run entab files...`

Convert spaces to tabs.

(koopa-run-eol-lf)=
## `run eol-lf files...`

Convert line endings to LF.

(koopa-run-extract)=
## `run extract files...`

Extract archives.

(koopa-run-extract-all)=
## `run extract-all files...`

Extract all archives.

(koopa-run-file-count)=
## `run file-count directory`

Count files in a directory.

(koopa-run-find-and-move-in-sequence)=
## `run find-and-move-in-sequence`

Find and move files in sequence (not yet implemented).

(koopa-run-find-and-replace)=
## `run find-and-replace pattern replacement files...`

Find and replace text in files.

- `--fixed`
- `--regex`

(koopa-run-find-broken-symlinks)=
## `run find-broken-symlinks dirs...`

Find broken symlinks.

(koopa-run-find-empty-dirs)=
## `run find-empty-dirs dirs...`

Find empty directories.

(koopa-run-find-files-without-line-ending)=
## `run find-files-without-line-ending directory`

Find files missing a final newline.

(koopa-run-find-large-dirs)=
## `run find-large-dirs directory`

Find large directories.

(koopa-run-find-large-files)=
## `run find-large-files directory`

Find large files.

(koopa-run-ifactive)=
## `run ifactive`

Show active network interfaces (macOS only).

(koopa-run-ip-address)=
## `run ip-address [--local|--public]`

Print IP address.

- `--local`
- `--public`

(koopa-run-ip-info)=
## `run ip-info`

Print public IP information.

(koopa-run-line-count)=
## `run line-count files...`

Count lines in files.

(koopa-run-merge-pdf)=
## `run merge-pdf files...`

Merge PDF files.

(koopa-run-move-files-in-batch)=
## `run move-files-in-batch --num N --source-dir DIR --target-dir DIR`

Move a batch of files between directories.

- `--num`
- `--source-dir`
- `--target-dir`

(koopa-run-move-files-up-1-level)=
## `run move-files-up-1-level [directory]`

Move files up one directory level.

(koopa-run-move-into-dated-dirs-by-filename)=
## `run move-into-dated-dirs-by-filename files...`

Move files into dated directories based on filename.

(koopa-run-move-into-dated-dirs-by-timestamp)=
## `run move-into-dated-dirs-by-timestamp files...`

Move files into dated directories based on timestamp.

(koopa-run-nfiletypes)=
## `run nfiletypes directory`

Count file types in a directory.

(koopa-run-rename-camel-case)=
## `run rename-camel-case paths...`

Rename files to camelCase.

(koopa-run-rename-from-csv)=
## `run rename-from-csv csv-file`

Rename files according to a CSV mapping.

(koopa-run-rename-kebab-case)=
## `run rename-kebab-case paths...`

Rename files to kebab-case.

(koopa-run-rename-lowercase)=
## `run rename-lowercase [--recursive] paths...`

Rename files to lowercase.

- `--recursive`

(koopa-run-rename-snake-case)=
## `run rename-snake-case paths...`

Rename files to snake_case.

(koopa-run-reset-terminal)=
## `run reset-terminal`

Reset a terminal left in a bad state by a dead SSH/tmux session.

(koopa-run-rg-sort)=
## `run rg-sort pattern`

Run ripgrep with results sorted by path.

(koopa-run-rg-unique)=
## `run rg-unique pattern`

Run ripgrep and return unique matches.

(koopa-run-sort-lines)=
## `run sort-lines files...`

Sort lines in files.

(koopa-run-spotlight)=
## `run spotlight query [directory]`

Search using macOS Spotlight (mdfind).

(koopa-run-tar-multiple-dirs)=
## `run tar-multiple-dirs dirs... [--delete|--no-delete]`

Create tar archives for multiple directories.

- `--delete`
- `--no-delete`

(koopa-run-update-today-bucket)=
## `run update-today-bucket`

Repoint the dated 'today bucket' symlink at today's directory.


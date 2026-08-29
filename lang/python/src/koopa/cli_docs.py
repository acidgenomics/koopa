"""Human-readable descriptions for koopa CLI commands.

Single source of truth for command metadata consumed by both
``generate_man.py`` (the ``koopa.1`` man page) and ``generate_docs.py`` (the
Sphinx CLI reference published to koopa.acidgenomics.com). Splitting this out
of the man-page generator means a second consumer never has to import
another generator's private tables.

Command names and platform tags are never duplicated here -- those live in
the authoritative dispatch tables (``generate_completion.py``'s
``_SYSTEM_COMMANDS``/``_ADMIN_COMMANDS``, ``cli_develop.py``'s
``_DEVELOP_HANDLERS``, ``cli_bin.py``'s ``_HANDLERS``, ``cli_app.py``'s
``_APP_TREE``). Only descriptions and argument synopses live here.
"""

# ---------------------------------------------------------------------------
# Top-level commands (``koopa install``, ``koopa app``, ...)
# ---------------------------------------------------------------------------

TOP_COMMANDS: list[tuple[str, str, str]] = [
    ("install", "[app...]", "Install applications. No args installs defaults; --all installs all."),
    ("reinstall", "app...", "Reinstall applications, with optional reverse dependency rebuilds."),
    (
        "uninstall",
        "[app...]",
        "Remove installed applications. Defaults to uninstalling koopa itself.",
    ),
    (
        "update",
        "[mode] [app...]",
        "Update koopa and stale apps; 'system' mode updates system apps.",
    ),
    ("list", "[--all]", "List available apps. No args lists defaults; --all lists all."),
    ("configure", "app...", "Run post-install configuration for applications."),
    ("app", "subcommand", "Application-specific utilities (e.g. koopa app salmon quant)."),
    ("run", "command", "Run a utility command (e.g. koopa run rename-snake-case)."),
    ("system", "subcommand", "System information and koopa management."),
    ("admin", "subcommand", "System administration commands (require sudo)."),
    ("develop", "subcommand", "Developer and maintenance utilities."),
]

INSTALL_FLAGS: list[tuple[str, str]] = [
    ("--all", "Install all registered applications."),
    ("--no-dependencies", "Skip dependency installation."),
    ("--reinstall", "Force reinstall even if already installed."),
    ("-D arg", "Pass additional arguments through to the installer. Can be repeated."),
]

REINSTALL_FLAGS: list[tuple[str, str]] = [
    ("--all-revdeps", "Reinstall the specified apps and all of their reverse dependencies."),
    ("--only-revdeps", "Reinstall only the reverse dependencies, not the specified apps."),
]

# ---------------------------------------------------------------------------
# ``koopa system`` subcommands
# ---------------------------------------------------------------------------

SYSTEM_DESCRIPTIONS: dict[str, str] = {
    "check": (
        "Run system checks, including dependency versions, broken app installs,"
        " bootstrap version, and disk usage."
    ),
    "hostname": "Print the system hostname.",
    "info": "Show system information.",
    "list": "List system information (subcommands: app-versions, launch-agents, path-priority).",
    "os-slug": "Print the operating system identifier slug.",
    "prefix": "Print the installation prefix for koopa or a named application.",
    "prune-apps": "Remove stale application versions.",
    "switch-to-develop": "Switch koopa installation to the development branch.",
    "version": "Print the installed version of an application.",
    "which": "Print the real path of an application.",
}

SYSTEM_SYNOPSIS: dict[str, str] = {
    "list": "subcommand",
    "prefix": "[name]",
    "spotlight": "query",
    "version": "name",
    "which": "name...",
}

# ---------------------------------------------------------------------------
# ``koopa admin`` subcommands (require sudo)
# ---------------------------------------------------------------------------

ADMIN_DESCRIPTIONS: dict[str, str] = {
    "clean-launch-services": "Clean the macOS Launch Services database.",
    "delete-cache": "Delete cache, log, and temporary files (Docker images only).",
    "disable-passwordless-sudo": "Disable passwordless sudo for the current user.",
    "disable-touch-id-sudo": "Disable Touch ID for sudo authentication.",
    "enable-passwordless-sudo": "Enable passwordless sudo for the current user.",
    "enable-touch-id-sudo": "Enable Touch ID for sudo authentication.",
    "fix-sudo-setrlimit-error": "Fix the sudo setrlimit error on Linux.",
    "flush-dns": "Flush the DNS cache.",
    "force-eject": "Force eject a mounted volume.",
    "reload-autofs": "Reload the autofs automount daemon.",
    "zsh-compaudit-set-permissions": "Fix Zsh compaudit permissions.",
    "add-group": "Add a system group.",
    "add-user": "Add a system user.",
    "apk-install": "Install packages with apk (Alpine).",
    "apk-remove": "Remove packages with apk (Alpine).",
    "apk-update": "Update the apk package index (Alpine).",
    "apt-install": "Install packages with apt (Debian/Ubuntu).",
    "apt-list-installed": "List installed apt packages (Debian/Ubuntu).",
    "apt-remove": "Remove packages with apt (Debian/Ubuntu).",
    "apt-update": "Update the apt package index (Debian/Ubuntu).",
    "apt-upgrade": "Upgrade installed packages with apt (Debian/Ubuntu).",
    "configure-lmod": "Configure Lmod environment modules at a prefix.",
    "configure-sshd": "Configure sshd port and authentication settings.",
    "delete-user": "Delete a system user.",
    "dnf-install": "Install packages with dnf (Fedora/RHEL).",
    "dnf-remove": "Remove packages with dnf (Fedora/RHEL).",
    "dnf-update": "Update installed packages with dnf (Fedora/RHEL).",
    "install-app": "Install a package using the native OS package manager.",
    "os-version": "Print the Linux OS version.",
    "pacman-install": "Install packages with pacman (Arch).",
    "pacman-remove": "Remove packages with pacman (Arch).",
    "pacman-update": "Update installed packages with pacman (Arch).",
    "proc-cmdline": "Print the kernel boot command line (/proc/cmdline).",
    "systemctl-disable": "Disable a systemd service.",
    "systemctl-restart": "Restart a systemd service.",
    "systemctl-status": "Print the status of a systemd service.",
    "systemctl-stop": "Stop a systemd service.",
    "uninstall-app": "Uninstall a package using the native OS package manager.",
    "zypper-install": "Install packages with zypper (openSUSE).",
    "zypper-remove": "Remove packages with zypper (openSUSE).",
    "zypper-update": "Update installed packages with zypper (openSUSE).",
}

ADMIN_SYNOPSIS: dict[str, str] = {
    "add-group": "name [--system]",
    "add-user": "name [--home DIR] [--shell SHELL] [--system] [--sudo]",
    "apk-install": "packages...",
    "apk-remove": "packages...",
    "apt-install": "packages...",
    "apt-remove": "packages...",
    "configure-lmod": "prefix",
    "delete-user": "name [--remove-home]",
    "dnf-install": "packages...",
    "dnf-remove": "packages...",
    "force-eject": "volume-name",
    "install-app": "name [--manager apt|dnf|apk|pacman|zypper]",
    "pacman-install": "packages...",
    "pacman-remove": "packages...",
    "systemctl-disable": "service",
    "systemctl-restart": "service",
    "systemctl-status": "service",
    "systemctl-stop": "service",
    "uninstall-app": "name [--manager apt|dnf|apk|pacman|zypper]",
    "zypper-install": "packages...",
    "zypper-remove": "packages...",
}

# ---------------------------------------------------------------------------
# ``koopa develop`` subcommands
# ---------------------------------------------------------------------------

DEVELOP_DESCRIPTIONS: dict[str, str] = {
    "audit-src-mirror": "Audit S3 source mirror for missing or stale tarballs.",
    "bump-revision": "Bump the revision of one or more apps in app.json.",
    "bump-venv-version": "Bump the Python venv version.",
    "cache-functions": "Regenerate the cached Bash function library.",
    "check-app-versions": "Check upstream versions for all apps in app.json.",
    "check-skills": "Validate SKILL.md frontmatter for cross-CLI compatibility.",
    "circular-dependencies": "Detect circular dependency chains in app.json.",
    "edit-app-json": "Open app.json in the default editor.",
    "format-app-json": "Sort and format app.json.",
    "generate-completion": "Regenerate shell tab-completion scripts.",
    "generate-docs": "Regenerate the Sphinx CLI reference pages under docs/reference/.",
    "generate-man": "Regenerate the koopa(1) man page.",
    "log": "View the latest temporary log file.",
    "mirror-src": "Mirror source tarballs to S3.",
    "prune-app-binaries": "Remove stale application binaries from the cache.",
    "push-all-app-builds": "Push all application builds to the binary cache.",
    "push-app-build": "Push a specific application build to the binary cache.",
    "push-app-builds": "Push all stale application builds to the binary cache.",
    "push-installer": "Stage a downloaded vendor installer tarball to the artifacts bucket.",
    "pytest": "Run the Python test suite.",
    "remove-app": "Tombstone an app entry in app.json.",
    "scrub-install-info": "Rewrite .install/info.json environ blocks down to the allowlist.",
    "shellcheck": "Run shellcheck on all shell scripts.",
    "update-docs": "Update generated documentation files.",
    "activation-fork-audit": "Static analysis of subprocess forks in the shell activation path.",
    "activation-speed-test": "Measure shell activation time and check against thresholds.",
    "app-deps": "List the dependencies of an app.",
    "app-revdeps": "List the reverse dependencies of an app.",
    "bump-bootstrap": "Bump the bootstrap version, marking existing bootstraps as stale.",
    "color-mode-audit": "Detect dark/light color-mode thrash in the sync log.",
    "conda-candidates": "Find source-built apps that are available on conda-forge or bioconda.",
    "find-ignored-bin-files": "Find files in bin/ that are ignored by git.",
    "orphan-apps": "Find apps in app.json that no other app depends on.",
    "pyright": "Run the pyright type checker on the Python source tree.",
    "reset-revisions": "Remove the revision key from all apps in app.json.",
}

DEVELOP_SYNOPSIS: dict[str, str] = {
    "bump-revision": "name...",
    "check-skills": "[path...]",
    "mirror-src": "name...",
    "push-app-build": "name...",
    "push-installer": "app file [--version version] [--force]",
    "remove-app": "name",
    "scrub-install-info": "[name...] [--dry-run]",
    "app-deps": "name",
    "app-revdeps": "name [--all]",
}

# ---------------------------------------------------------------------------
# ``koopa run`` commands
# ---------------------------------------------------------------------------

RUN_DESCRIPTIONS: dict[str, str] = {
    "autopad-zeros": "Autopad zeros in numbered file names.",
    "clone": "Clone directory contents using rsync.",
    "convert-svg-to-png": "Convert SVG files to PNG using macOS sips.",
    "convert-utf8-nfd-to-nfc": "Convert UTF-8 NFD filenames to NFC.",
    "create-dmg": "Create a DMG disk image from a source folder.",
    "delete-broken-symlinks": "Delete broken symlinks.",
    "delete-empty-dirs": "Delete empty directories.",
    "delete-named-subdirs": "Delete subdirectories matching a name.",
    "detab": "Convert tabs to spaces.",
    "df2": "Wrapper around df with improved defaults.",
    "dns": "Print DNS records and nameserver provider for a domain.",
    "dot-clean": "Remove dot files and macOS cruft.",
    "download": "Download a file from a URL.",
    "download-cran-latest": "Download latest CRAN package source.",
    "download-github-latest": "Download latest GitHub release asset.",
    "entab": "Convert spaces to tabs.",
    "eol-lf": "Convert line endings to LF.",
    "extract": "Extract archives.",
    "extract-all": "Extract all archives.",
    "file-count": "Count files in a directory.",
    "find-and-move-in-sequence": "Find and move files in sequence (not yet implemented).",
    "find-and-replace": "Find and replace text in files.",
    "find-broken-symlinks": "Find broken symlinks.",
    "find-empty-dirs": "Find empty directories.",
    "find-files-without-line-ending": "Find files missing a final newline.",
    "find-large-dirs": "Find large directories.",
    "find-large-files": "Find large files.",
    "ifactive": "Show active network interfaces (macOS only).",
    "ip-address": "Print IP address.",
    "ip-info": "Print public IP information.",
    "line-count": "Count lines in files.",
    "merge-pdf": "Merge PDF files.",
    "move-files-in-batch": "Move a batch of files between directories.",
    "move-files-up-1-level": "Move files up one directory level.",
    "move-into-dated-dirs-by-filename": "Move files into dated directories based on filename.",
    "move-into-dated-dirs-by-timestamp": "Move files into dated directories based on timestamp.",
    "nfiletypes": "Count file types in a directory.",
    "rename-camel-case": "Rename files to camelCase.",
    "rename-from-csv": "Rename files according to a CSV mapping.",
    "rename-kebab-case": "Rename files to kebab-case.",
    "rename-lowercase": "Rename files to lowercase.",
    "rename-snake-case": "Rename files to snake_case.",
    "reset-terminal": "Reset a terminal left in a bad state by a dead SSH/tmux session.",
    "rg-sort": "Run ripgrep with results sorted by path.",
    "rg-unique": "Run ripgrep and return unique matches.",
    "sort-lines": "Sort lines in files.",
    "spotlight": "Search using macOS Spotlight (mdfind).",
    "tar-multiple-dirs": "Create tar archives for multiple directories.",
    "update-today-bucket": "Repoint the dated 'today bucket' symlinks at today's directory.",
}

RUN_SYNOPSIS: dict[str, str] = {
    "autopad-zeros": "directory",
    "clone": "source target",
    "convert-svg-to-png": "files...",
    "convert-utf8-nfd-to-nfc": "paths...",
    "create-dmg": "source-folder",
    "delete-broken-symlinks": "dirs...",
    "delete-empty-dirs": "dirs...",
    "delete-named-subdirs": "directory name",
    "detab": "files...",
    "dns": "domain",
    "dot-clean": "directory",
    "download": "url [output]",
    "download-cran-latest": "packages...",
    "download-github-latest": "repo [--pattern glob]",
    "entab": "files...",
    "eol-lf": "files...",
    "extract": "files...",
    "extract-all": "files...",
    "file-count": "directory",
    "find-and-replace": "pattern replacement files...",
    "find-broken-symlinks": "dirs...",
    "find-empty-dirs": "dirs...",
    "find-files-without-line-ending": "directory",
    "find-large-dirs": "directory",
    "find-large-files": "directory",
    "ip-address": "[--local|--public]",
    "line-count": "files...",
    "merge-pdf": "files...",
    "move-files-in-batch": "--num N --source-dir DIR --target-dir DIR",
    "move-files-up-1-level": "[directory]",
    "move-into-dated-dirs-by-filename": "files...",
    "move-into-dated-dirs-by-timestamp": "files...",
    "nfiletypes": "directory",
    "rename-camel-case": "paths...",
    "rename-from-csv": "csv-file",
    "rename-kebab-case": "paths...",
    "rename-lowercase": "[--recursive] paths...",
    "rename-snake-case": "paths...",
    "rg-sort": "pattern",
    "rg-unique": "pattern",
    "sort-lines": "files...",
    "spotlight": "query [directory]",
    "tar-multiple-dirs": "dirs... [--delete|--no-delete]",
}

# ---------------------------------------------------------------------------
# ``koopa app`` namespaces and leaf subcommands
# ---------------------------------------------------------------------------

APP_NAMESPACE_DESCRIPTIONS: dict[str, str] = {
    "aws": "AWS utilities (Batch, EC2, ECR, S3).",
    "bioconda": "bioconda-recipes maintenance utilities.",
    "bowtie2": "Bowtie 2 short-read aligner wrappers.",
    "brew": "Homebrew maintenance utilities.",
    "claude": "Claude Code configuration maintenance utilities.",
    "conda": "conda environment management utilities.",
    "current": "Query the current upstream version of a package or resource.",
    "docker": "Docker image build, run, and cleanup utilities.",
    "ftp": "FTP mirroring utilities.",
    "file": "File compression and renaming utilities.",
    "git": "Git repository maintenance utilities.",
    "gpg": "GnuPG agent management utilities.",
    "hisat2": "HISAT2 spliced aligner wrappers.",
    "jekyll": "Jekyll static site build and deploy utilities.",
    "kallisto": "kallisto pseudo-alignment wrappers.",
    "koopa": "koopa.acidgenomics.com Sphinx docs site publishing.",
    "md5sum": "md5sum checksum utilities.",
    "photos": "Photo and video file renaming utilities.",
    "miso": "MISO alternative-splicing index utilities.",
    "python": "python.acidgenomics.com package index and docs publishing.",
    "r": "r.acidgenomics.com R package repository publishing.",
    "rnaeditingindexer": "RNA editing indexer wrapper.",
    "rsem": "RSEM transcript quantification wrappers.",
    "salmon": "salmon transcript quantification wrappers.",
    "sra": "SRA (Sequence Read Archive) download utilities.",
    "ssh": "SSH key generation utilities.",
    "sys": "Low-level system inspection utilities.",
    "star": "STAR spliced aligner wrappers.",
    "wget": "wget recursive mirroring utilities.",
}

# Keyed by the _APP_TREE leaf handler key (e.g. "r-publish-docs"), matching how
# cli_app._PYTHON_HANDLERS / cli_system._ADMIN_HANDLERS are already keyed, so
# the two can be cross-checked programmatically.
APP_DESCRIPTIONS: dict[str, str] = {
    # aws
    "aws-batch-fetch-and-run": "Submit an AWS Batch fetch-and-run job.",
    "aws-batch-list-jobs": "List AWS Batch jobs in a queue.",
    "aws-ec2-instance-id": "Print the current EC2 instance ID.",
    "aws-ec2-list-running-instances": "List running EC2 instances.",
    "aws-ec2-map-instance-ids-to-names": "Map EC2 instance IDs to Name tags.",
    "aws-ec2-stop": "Stop EC2 instances.",
    "aws-ecr-login-private": "Authenticate Docker to a private ECR registry.",
    "aws-ecr-login-public": "Authenticate Docker to the public ECR gallery.",
    "aws-s3-delete-versioned-glacier-objects": (
        "Delete versioned Glacier objects from an S3 bucket."
    ),
    "aws-s3-delete-versioned-objects": "Delete versioned objects from an S3 bucket.",
    "aws-s3-dot-clean": "Remove macOS dot-files from an S3 path.",
    "aws-s3-find": "Find S3 keys matching a pattern under a prefix.",
    "aws-s3-list-large-files": "List S3 objects above a size threshold.",
    "aws-s3-ls": "List an S3 path.",
    "aws-s3-mv-to-parent": "Move S3 objects up one directory level.",
    "aws-s3-sync": "Sync files between local and S3, or between S3 buckets.",
    "aws-s3-sync-git-repo": "Sync a local git repo to S3, respecting .gitignore.",
    # bioconda
    "bioconda-autobump-recipe": "Check out a bioconda-recipes autobump PR branch for review.",
    # bowtie2 / hisat2 / kallisto / miso / rnaeditingindexer / rsem / salmon / star
    "bowtie2-align-paired-end": "Align paired-end reads with Bowtie 2.",
    "bowtie2-index": "Build a Bowtie 2 genome index.",
    "hisat2-align-paired-end": "Align paired-end reads with HISAT2.",
    "hisat2-align-single-end": "Align single-end reads with HISAT2.",
    "hisat2-index": "Build a HISAT2 genome index.",
    "kallisto-index": "Build a kallisto transcriptome index.",
    "kallisto-quant-paired-end": "Quantify paired-end reads with kallisto.",
    "kallisto-quant-single-end": "Quantify single-end reads with kallisto.",
    "miso-index": "Build a MISO alternative-splicing index.",
    "rnaeditingindexer": "Run the RNA editing indexer on a directory of BAM files.",
    "rsem-index": "Build an RSEM reference index.",
    "rsem-quant-bam": "Quantify transcript expression from a BAM file with RSEM.",
    "salmon-detect-fastq-library-type": "Detect the FASTQ library type using salmon.",
    "salmon-index": "Build a salmon transcriptome index.",
    "salmon-quant-bam": "Quantify transcript expression from a BAM file with salmon.",
    "salmon-quant-paired-end": "Quantify paired-end reads with salmon.",
    "salmon-quant-single-end": "Quantify single-end reads with salmon.",
    "star-align-paired-end": "Align paired-end reads with STAR.",
    "star-align-single-end": "Align single-end reads with STAR.",
    "star-index": "Build a STAR genome index.",
    # brew
    "brew-cleanup": "Run 'brew cleanup'.",
    "brew-dump-brewfile": "Dump the current Homebrew Bundle to a Brewfile.",
    "brew-fix-completion-dirs": "Create shell completion dirs a cask sandbox can't create itself.",
    "brew-install-bundle": "Install packages from a Brewfile via 'brew bundle'.",
    "brew-outdated": "List outdated Homebrew packages.",
    "brew-reset-core-repo": "Reset the homebrew/core git repo to match its remote.",
    "brew-reset-permissions": "Reset ownership and permissions on the Homebrew prefix.",
    "brew-uninstall-all-brews": "Uninstall all Homebrew-managed packages.",
    "brew-upgrade": "Upgrade all Homebrew packages.",
    "brew-version": "Print the installed Homebrew version.",
    # claude
    "claude-archive-plans": "Archive old Claude Code plan files into date-based subdirectories.",
    "claude-audit-tokens": "Report approximate token cost of Claude config files.",
    # conda
    "conda-clean-cache": "Clean the conda package cache.",
    "conda-create-env": "Create a conda environment from packages or an environment file.",
    "conda-remove-env": "Remove a conda environment.",
    # current (version lookups)
    "current-aws-cli-version": "Print the current upstream AWS CLI version.",
    "current-bioconductor-version": "Print the current Bioconductor release version.",
    "current-conda-package-version": "Print the current version of a conda package.",
    "current-ensembl-version": "Print the current Ensembl release version.",
    "current-flybase-version": "Print the current FlyBase release version.",
    "current-gencode-version": "Print the current GENCODE release version.",
    "current-git-version": "Print the current upstream Git version.",
    "current-github-release-version": "Print the latest GitHub release version for a repo.",
    "current-github-tag-version": "Print the latest GitHub tag version for a repo.",
    "current-gnu-ftp-version": "Print the current version of a GNU FTP-hosted package.",
    "current-google-cloud-sdk-version": "Print the current upstream Google Cloud SDK version.",
    "current-latch-version": "Print the current Latch SDK version.",
    "current-pypi-package-version": "Print the current version of a PyPI package.",
    "current-python-version": "Print the current upstream Python version.",
    "current-refseq-version": "Print the current RefSeq release version.",
    "current-wormbase-version": "Print the current WormBase release version.",
    # docker
    "docker-build": "Build a Docker image for local and/or remote platforms.",
    "docker-build-all-tags": "Build Docker images for all tags in a repo.",
    "docker-prune-all-images": "Remove all local Docker images.",
    "docker-prune-old-images": "Remove old, unused local Docker images.",
    "docker-remove": "Remove Docker images matching a pattern.",
    "docker-run": "Run a Docker image, with platform and bind-mount shortcuts.",
    # file
    "file-compress": "Compress a file or directory into a tar.gz archive.",
    "file-convert-line-endings": "Convert CRLF line endings to LF in place.",
    "file-rename-to-lowercase-ext": "Rename file extensions to lowercase.",
    # ftp
    "ftp-mirror": "Mirror an FTP site with wget.",
    # git
    "git-pull": "Pull the latest changes in a git repo.",
    "git-push-submodules": "Push all git submodules in a repo.",
    "git-rename-master-to-main": "Rename a repo's master branch to main.",
    "git-reset": "Hard-reset a git repo to its upstream branch.",
    "git-reset-fork-to-upstream": "Reset a forked repo to match its upstream.",
    "git-rm-submodule": "Remove a git submodule.",
    "git-rm-untracked": "Remove untracked files from a git repo.",
    # gpg
    "gpg-prompt": "Prompt for the GPG passphrase to unlock the agent.",
    "gpg-reload": "Reload the GPG agent.",
    "gpg-restart": "Restart the GPG agent.",
    # jekyll
    "jekyll-deploy-to-aws": "Build a Jekyll site and deploy it to S3 + CloudFront.",
    "jekyll-serve": "Serve a Jekyll site locally for development.",
    # koopa (site)
    "koopa-prune-stale-docs": "Remove stale S3 keys left over from a previous docs build.",
    "koopa-publish-docs": "Build and publish the koopa Sphinx docs site to koopa.acidgenomics.com.",
    # md5sum
    "md5sum-check-to-new-md5-file": "Compute md5sum checksums and log them to a new .md5 file.",
    # photos
    "photos-rename-with-exiftool": "Rename photos and videos by capture date using exiftool.",
    # python
    "python-publish": "Build and publish a Python package to python.acidgenomics.com.",
    "python-publish-docs": "Build and publish a package's Sphinx docs to python.acidgenomics.com.",
    "python-reindex": "Regenerate the PEP 503 index and landing page for python.acidgenomics.com.",
    "python-sync-docs-theme": "Sync koopa's shared Sphinx theme into one or more doc trees.",
    # r
    "r-archive": "Archive stale R package source tarballs.",
    "r-bioconda-check": "Check R package versions against bioconda-recipes.",
    "r-clean-orphan-binaries": "Remove orphaned R package binaries with no matching source.",
    "r-check": "Run R CMD check on an R package.",
    "r-configure-environ": "Configure R's Renviron file.",
    "r-configure-java": "Configure R's Java bindings.",
    "r-configure-ldpaths": "Configure R's shared library search paths.",
    "r-configure-makevars": "Configure R's Makevars build settings.",
    "r-copy-files-into-etc": "Copy koopa R configuration files into R's etc/ directory.",
    "r-deploy": "Deploy the current state of r.acidgenomics.com.",
    "r-gfortran-libs": "Print the gfortran runtime library search path.",
    "r-install-packages-in-site-library": "Install R packages into the site library.",
    "r-package-version": "Print the installed version of an R package.",
    "r-paste-to-vector": "Format items as an R character vector literal.",
    "r-publish": "Build, check, and publish an R package to r.acidgenomics.com.",
    "r-publish-docs": "Build and publish an R package's pkgdown docs to r.acidgenomics.com.",
    "r-publish-from-github": "Publish an R package release directly from its GitHub repo.",
    "r-reindex": "Regenerate the drat index and landing page for r.acidgenomics.com.",
    "r-remove-packages-in-system-library": "Remove non-base packages from R's system library.",
    "r-script": "Run an R script with koopa's R.",
    "r-shiny-run-app": "Run a Shiny app locally.",
    "r-system-packages-non-base": "List non-base packages installed in R's system library.",
    "r-version": "Print the installed R version.",
    # sra
    "sra-download-accession-list": "Download the accession list for an SRA study.",
    "sra-download-run-info-table": "Download the run info table for an SRA study.",
    "sra-fastq-dump": "Extract FASTQ files from prefetched SRA data.",
    "sra-prefetch": "Prefetch SRA run data by accession.",
    # ssh
    "ssh-generate-key": "Generate one or more SSH key pairs.",
    # sys
    "sys-linker-info": "Show shared library dependencies (ldd on Linux, otool -L on macOS).",
    # wget
    "wget-recursive": "Recursively mirror a password-protected site with wget.",
}

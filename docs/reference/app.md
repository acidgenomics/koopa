# koopa app

## aws

AWS utilities (Batch, EC2, ECR, S3).

(koopa-app-aws-batch-fetch-and-run)=
### `app aws batch fetch-and-run`

Submit an AWS Batch fetch-and-run job.

- `--queue`
- `--job-definition`
- `--job-name`
- `--vcpus`
- `--memory`
- `--profile`

(koopa-app-aws-batch-list-jobs)=
### `app aws batch list-jobs`

List AWS Batch jobs in a queue.

- `--queue`
- `--status`
- `--profile`

(koopa-app-aws-ec2-instance-id)=
### `app aws ec2 instance-id`

Print the current EC2 instance ID.

(koopa-app-aws-ec2-list-running-instances)=
### `app aws ec2 list-running-instances`

List running EC2 instances.

- `--profile`

(koopa-app-aws-ec2-map-instance-ids-to-names)=
### `app aws ec2 map-instance-ids-to-names`

Map EC2 instance IDs to Name tags.

- `--profile`

(koopa-app-aws-ec2-stop)=
### `app aws ec2 stop`

Stop EC2 instances.

- `--profile`

(koopa-app-aws-ecr-login-private)=
### `app aws ecr login-private`

Authenticate Docker to a private ECR registry.

- `--region`
- `--account-id`
- `--profile`

(koopa-app-aws-ecr-login-public)=
### `app aws ecr login-public`

Authenticate Docker to the public ECR gallery.

- `--region`

(koopa-app-aws-s3-delete-versioned-glacier-objects)=
### `app aws s3 delete-versioned-glacier-objects`

Delete versioned Glacier objects from an S3 bucket.

- `--bucket`
- `--prefix`
- `--profile`

(koopa-app-aws-s3-delete-versioned-objects)=
### `app aws s3 delete-versioned-objects`

Delete versioned objects from an S3 bucket.

- `--bucket`
- `--prefix`
- `--profile`

(koopa-app-aws-s3-dot-clean)=
### `app aws s3 dot-clean`

Remove macOS dot-files from an S3 path.

- `--dryrun`
- `--profile`

(koopa-app-aws-s3-find)=
### `app aws s3 find`

Find S3 keys matching a pattern under a prefix.

- `--bucket`
- `--prefix`
- `--pattern`
- `--profile`

(koopa-app-aws-s3-list-large-files)=
### `app aws s3 list-large-files`

List S3 objects above a size threshold.

- `--bucket`
- `--min-size-mb`
- `--prefix`
- `--profile`

(koopa-app-aws-s3-ls)=
### `app aws s3 ls`

List an S3 path.

- `--recursive`
- `--profile`

(koopa-app-aws-s3-mv-to-parent)=
### `app aws s3 mv-to-parent`

Move S3 objects up one directory level.

- `--dryrun`
- `--profile`

(koopa-app-aws-s3-sync)=
### `app aws s3 sync`

Sync files between local and S3, or between S3 buckets.

- `--delete`
- `--dryrun`
- `--exclude`
- `--include`
- `--profile`

(koopa-app-aws-s3-sync-git-repo)=
### `app aws s3 sync-git-repo`

Sync a local git repo to S3, respecting .gitignore.

- `--delete`
- `--dryrun`
- `--profile`

## bioconda

bioconda-recipes maintenance utilities.

(koopa-app-bioconda-autobump-recipe)=
### `app bioconda autobump-recipe`

Check out a bioconda-recipes autobump PR branch for review.

## bowtie2

Bowtie 2 short-read aligner wrappers.

(koopa-app-bowtie2-align-paired-end)=
### `app bowtie2 align paired-end`

Align paired-end reads with Bowtie 2.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`
- `--output-format`
- `--reference-fasta`

(koopa-app-bowtie2-index)=
### `app bowtie2 index`

Build a Bowtie 2 genome index.

- `--genome-fasta-file`
- `--output-dir`

## brew

Homebrew maintenance utilities.

(koopa-app-brew-cleanup)=
### `app brew cleanup`

Run 'brew cleanup'.

(koopa-app-brew-dump-brewfile)=
### `app brew dump-brewfile`

Dump the current Homebrew Bundle to a Brewfile.

(koopa-app-brew-fix-completion-dirs)=
### `app brew fix-completion-dirs`

Create shell completion dirs a cask sandbox can't create itself.

(koopa-app-brew-install-bundle)=
### `app brew install-bundle`

Install packages from a Brewfile via 'brew bundle'.

(koopa-app-brew-outdated)=
### `app brew outdated`

List outdated Homebrew packages.

(koopa-app-brew-reset-core-repo)=
### `app brew reset-core-repo`

Reset the homebrew/core git repo to match its remote.

(koopa-app-brew-reset-permissions)=
### `app brew reset-permissions`

Reset ownership and permissions on the Homebrew prefix.

(koopa-app-brew-uninstall-all-brews)=
### `app brew uninstall-all-brews`

Uninstall all Homebrew-managed packages.

(koopa-app-brew-upgrade)=
### `app brew upgrade`

Upgrade all Homebrew packages.

(koopa-app-brew-version)=
### `app brew version`

Print the installed Homebrew version.

## claude

Claude Code configuration maintenance utilities.

(koopa-app-claude-archive-plans)=
### `app claude archive-plans`

Archive old Claude Code plan files into date-based subdirectories.

- `--days`
- `--dry-run`

(koopa-app-claude-audit-tokens)=
### `app claude audit-tokens`

Report approximate token cost of Claude config files.

- `--max-tokens`
- `--scope`
- `--project-dir`

## conda

conda environment management utilities.

(koopa-app-conda-clean-cache)=
### `app conda clean-cache`

Clean the conda package cache.

(koopa-app-conda-create-env)=
### `app conda create-env`

Create a conda environment from packages or an environment file.

- `--file`
- `--prefix`
- `--force`
- `--latest`

(koopa-app-conda-remove-env)=
### `app conda remove-env`

Remove a conda environment.

## current

Query the current upstream version of a package or resource.

(koopa-app-current-aws-cli-version)=
### `app current aws-cli-version`

Print the current upstream AWS CLI version.

(koopa-app-current-bioconductor-version)=
### `app current bioconductor-version`

Print the current Bioconductor release version.

(koopa-app-current-conda-package-version)=
### `app current conda-package-version`

Print the current version of a conda package.

(koopa-app-current-ensembl-version)=
### `app current ensembl-version`

Print the current Ensembl release version.

(koopa-app-current-flybase-version)=
### `app current flybase-version`

Print the current FlyBase release version.

(koopa-app-current-gencode-version)=
### `app current gencode-version`

Print the current GENCODE release version.

(koopa-app-current-git-version)=
### `app current git-version`

Print the current upstream Git version.

(koopa-app-current-github-release-version)=
### `app current github-release-version`

Print the latest GitHub release version for a repo.

(koopa-app-current-github-tag-version)=
### `app current github-tag-version`

Print the latest GitHub tag version for a repo.

(koopa-app-current-gnu-ftp-version)=
### `app current gnu-ftp-version`

Print the current version of a GNU FTP-hosted package.

(koopa-app-current-google-cloud-sdk-version)=
### `app current google-cloud-sdk-version`

Print the current upstream Google Cloud SDK version.

(koopa-app-current-latch-version)=
### `app current latch-version`

Print the current Latch SDK version.

(koopa-app-current-pypi-package-version)=
### `app current pypi-package-version`

Print the current version of a PyPI package.

(koopa-app-current-python-version)=
### `app current python-version`

Print the current upstream Python version.

(koopa-app-current-refseq-version)=
### `app current refseq-version`

Print the current RefSeq release version.

(koopa-app-current-wormbase-version)=
### `app current wormbase-version`

Print the current WormBase release version.

## docker

Docker image build, run, and cleanup utilities.

(koopa-app-docker-build)=
### `app docker build`

Build a Docker image for local and/or remote platforms.

- `--local`
- `--remote`
- `--memory`
- `--no-push`

(koopa-app-docker-build-all-tags)=
### `app docker build-all-tags`

Build Docker images for all tags in a repo.

- `--local`
- `--remote`

(koopa-app-docker-prune-all-images)=
### `app docker prune-all-images`

Remove all local Docker images.

(koopa-app-docker-prune-old-images)=
### `app docker prune-old-images`

Remove old, unused local Docker images.

(koopa-app-docker-remove)=
### `app docker remove`

Remove Docker images matching a pattern.

(koopa-app-docker-run)=
### `app docker run`

Run a Docker image, with platform and bind-mount shortcuts.

- `--arm`
- `--x86`
- `--bash`
- `--bind`

## file

File compression and renaming utilities.

(koopa-app-file-compress)=
### `app file compress`

Compress a file or directory into a tar.gz archive.

- `--output`

(koopa-app-file-convert-line-endings)=
### `app file convert-line-endings`

Convert CRLF line endings to LF in place.

(koopa-app-file-rename-to-lowercase-ext)=
### `app file rename-to-lowercase-ext`

Rename file extensions to lowercase.

## ftp

FTP mirroring utilities.

(koopa-app-ftp-mirror)=
### `app ftp mirror`

Mirror an FTP site with wget.

- `--host`
- `--user`
- `--dir`

## git

Git repository maintenance utilities.

(koopa-app-git-pull)=
### `app git pull`

Pull the latest changes in a git repo.

(koopa-app-git-push-submodules)=
### `app git push-submodules`

Push all git submodules in a repo.

(koopa-app-git-rename-master-to-main)=
### `app git rename-master-to-main`

Rename a repo's master branch to main.

(koopa-app-git-reset)=
### `app git reset`

Hard-reset a git repo to its upstream branch.

(koopa-app-git-reset-fork-to-upstream)=
### `app git reset-fork-to-upstream`

Reset a forked repo to match its upstream.

(koopa-app-git-rm-submodule)=
### `app git rm-submodule`

Remove a git submodule.

(koopa-app-git-rm-untracked)=
### `app git rm-untracked`

Remove untracked files from a git repo.

## gpg

GnuPG agent management utilities.

(koopa-app-gpg-prompt)=
### `app gpg prompt`

Prompt for the GPG passphrase to unlock the agent.

(koopa-app-gpg-reload)=
### `app gpg reload`

Reload the GPG agent.

(koopa-app-gpg-restart)=
### `app gpg restart`

Restart the GPG agent.

## hisat2

HISAT2 spliced aligner wrappers.

(koopa-app-hisat2-align-paired-end)=
### `app hisat2 align paired-end`

Align paired-end reads with HISAT2.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`
- `--gtf-file`

(koopa-app-hisat2-align-single-end)=
### `app hisat2 align single-end`

Align single-end reads with HISAT2.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`
- `--gtf-file`

(koopa-app-hisat2-index)=
### `app hisat2 index`

Build a HISAT2 genome index.

- `--genome-fasta-file`
- `--output-dir`
- `--gtf-file`

## jekyll

Jekyll static site build and deploy utilities.

(koopa-app-jekyll-deploy-to-aws)=
### `app jekyll deploy-to-aws`

Build a Jekyll site and deploy it to S3 + CloudFront.

- `--bucket`
- `--distribution-id`
- `--profile`
- `--local-prefix`

(koopa-app-jekyll-serve)=
### `app jekyll serve`

Serve a Jekyll site locally for development.

## kallisto

kallisto pseudo-alignment wrappers.

(koopa-app-kallisto-index)=
### `app kallisto index`

Build a kallisto transcriptome index.

- `--transcriptome-fasta-file`
- `--output-dir`

(koopa-app-kallisto-quant-paired-end)=
### `app kallisto quant paired-end`

Quantify paired-end reads with kallisto.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`

(koopa-app-kallisto-quant-single-end)=
### `app kallisto quant single-end`

Quantify single-end reads with kallisto.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`

## koopa

koopa.acidgenomics.com Sphinx docs site publishing.

(koopa-app-koopa-prune-stale-docs)=
### `app koopa prune-stale-docs`

Remove stale S3 keys left over from a previous docs build.

- `--no-dryrun`

(koopa-app-koopa-publish-docs)=
### `app koopa publish-docs`

Build and publish the koopa Sphinx docs site to koopa.acidgenomics.com.

- `--no-invalidate`
- `--dryrun`

## md5sum

md5sum checksum utilities.

(koopa-app-md5sum-check-to-new-md5-file)=
### `app md5sum check-to-new-md5-file`

Compute md5sum checksums and log them to a new .md5 file.

## miso

MISO alternative-splicing index utilities.

(koopa-app-miso-index)=
### `app miso index`

Build a MISO alternative-splicing index.

- `--gff-file`
- `--output-dir`

## photos

Photo and video file renaming utilities.

(koopa-app-photos-rename-with-exiftool)=
### `app photos rename-with-exiftool`

Rename photos and videos by capture date using exiftool.

## python

python.acidgenomics.com package index and docs publishing.

(koopa-app-python-publish)=
### `app python publish`

Build and publish a Python package to PyPI and python.acidgenomics.com.

- `--force`
- `--no-pypi`
- `--pypi-only`

(koopa-app-python-publish-docs)=
### `app python publish-docs`

Build and publish a package's Sphinx docs to python.acidgenomics.com.

(koopa-app-python-reindex)=
### `app python reindex`

Regenerate the PEP 503 index and landing page for python.acidgenomics.com.

(koopa-app-python-sync-docs-theme)=
### `app python sync-docs-theme`

Sync koopa's shared Sphinx theme into one or more doc trees.

- `--check`

## r

r.acidgenomics.com R package repository publishing.

(koopa-app-r-archive)=
### `app r archive`

Archive stale R package source tarballs.

- `--no-invalidate`

(koopa-app-r-bioconda-check)=
### `app r bioconda-check`

Check R package versions against bioconda-recipes.

(koopa-app-r-check)=
### `app r check`

Run R CMD check on an R package.

(koopa-app-r-clean-orphan-binaries)=
### `app r clean-orphan-binaries`

Remove orphaned R package binaries with no matching source.

- `--no-invalidate`

(koopa-app-r-configure-environ)=
### `app r configure-environ`

Configure R's Renviron file.

(koopa-app-r-configure-java)=
### `app r configure-java`

Configure R's Java bindings.

(koopa-app-r-configure-ldpaths)=
### `app r configure-ldpaths`

Configure R's shared library search paths.

(koopa-app-r-configure-makevars)=
### `app r configure-makevars`

Configure R's Makevars build settings.

(koopa-app-r-copy-files-into-etc)=
### `app r copy-files-into-etc`

Copy koopa R configuration files into R's etc/ directory.

(koopa-app-r-deploy)=
### `app r deploy`

Deploy the current state of r.acidgenomics.com.

- `--no-invalidate`

(koopa-app-r-gfortran-libs)=
### `app r gfortran-libs`

Print the gfortran runtime library search path.

(koopa-app-r-install-packages-in-site-library)=
### `app r install-packages-in-site-library`

Install R packages into the site library.

(koopa-app-r-package-version)=
### `app r package-version`

Print the installed version of an R package.

(koopa-app-r-paste-to-vector)=
### `app r paste-to-vector`

Format items as an R character vector literal.

(koopa-app-r-publish)=
### `app r publish`

Build, check, and publish an R package to r.acidgenomics.com.

- `--no-check`
- `--no-deploy`
- `--no-invalidate`
- `--no-tag`

(koopa-app-r-publish-docs)=
### `app r publish-docs`

Build and publish an R package's pkgdown docs to r.acidgenomics.com.

- `--no-invalidate`

(koopa-app-r-publish-from-github)=
### `app r publish-from-github`

Publish an R package release directly from its GitHub repo.

- `--org`
- `--check`
- `--no-invalidate`

(koopa-app-r-reindex)=
### `app r reindex`

Regenerate the drat index and landing page for r.acidgenomics.com.

- `--no-invalidate`

(koopa-app-r-remove-packages-in-system-library)=
### `app r remove-packages-in-system-library`

Remove non-base packages from R's system library.

(koopa-app-r-script)=
### `app r script`

Run an R script with koopa's R.

(koopa-app-r-shiny-run-app)=
### `app r shiny-run-app`

Run a Shiny app locally.

- `--port`

(koopa-app-r-system-packages-non-base)=
### `app r system-packages-non-base`

List non-base packages installed in R's system library.

(koopa-app-r-version)=
### `app r version`

Print the installed R version.

## rnaeditingindexer

RNA editing indexer wrapper.

(koopa-app-rnaeditingindexer)=
### `app rnaeditingindexer`

Run the RNA editing indexer on a directory of BAM files.

- `--bam-dir`
- `--output-dir`
- `--genome`
- `--example`

## rsem

RSEM transcript quantification wrappers.

(koopa-app-rsem-index)=
### `app rsem index`

Build an RSEM reference index.

- `--genome-fasta-file`
- `--output-dir`
- `--gtf-file`
- `--num-threads`

(koopa-app-rsem-quant-bam)=
### `app rsem quant bam`

Quantify transcript expression from a BAM file with RSEM.

- `--bam-file`
- `--index-dir`
- `--output-dir`

## salmon

salmon transcript quantification wrappers.

(koopa-app-salmon-detect-fastq-library-type)=
### `app salmon detect-fastq-library-type`

Detect the FASTQ library type using salmon.

- `--index-dir`
- `--r1`
- `--r2`
- `--threads`

(koopa-app-salmon-index)=
### `app salmon index`

Build a salmon transcriptome index.

- `--transcriptome-fasta-file`
- `--output-dir`

(koopa-app-salmon-quant-bam)=
### `app salmon quant bam`

Quantify transcript expression from a BAM file with salmon.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`

(koopa-app-salmon-quant-paired-end)=
### `app salmon quant paired-end`

Quantify paired-end reads with salmon.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`

(koopa-app-salmon-quant-single-end)=
### `app salmon quant single-end`

Quantify single-end reads with salmon.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`

## sra

SRA (Sequence Read Archive) download utilities.

(koopa-app-sra-download-accession-list)=
### `app sra download-accession-list`

Download the accession list for an SRA study.

- `--srp-id`
- `--file`

(koopa-app-sra-download-run-info-table)=
### `app sra download-run-info-table`

Download the run info table for an SRA study.

- `--srp-id`
- `--file`

(koopa-app-sra-fastq-dump)=
### `app sra fastq-dump`

Extract FASTQ files from prefetched SRA data.

- `--prefetch-directory`
- `--fastq-directory`
- `--no-compress`

(koopa-app-sra-prefetch)=
### `app sra prefetch`

Prefetch SRA run data by accession.

- `--accession-file`
- `--output-dir`

## ssh

SSH key generation utilities.

(koopa-app-ssh-generate-key)=
### `app ssh generate-key`

Generate one or more SSH key pairs.

- `--prefix`

## star

STAR spliced aligner wrappers.

(koopa-app-star-align-paired-end)=
### `app star align paired-end`

Align paired-end reads with STAR.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`
- `--gtf-file`

(koopa-app-star-align-single-end)=
### `app star align single-end`

Align single-end reads with STAR.

- `--index-dir`
- `--fastq-dir`
- `--output-dir`
- `--gtf-file`

(koopa-app-star-index)=
### `app star index`

Build a STAR genome index.

- `--genome-fasta-file`
- `--output-dir`
- `--gtf-file`

## sys

Low-level system inspection utilities.

(koopa-app-sys-linker-info)=
### `app sys linker-info`

Show shared library dependencies (ldd on Linux, otool -L on macOS).

## wget

wget recursive mirroring utilities.

(koopa-app-wget-recursive)=
### `app wget recursive`

Recursively mirror a password-protected site with wget.

- `--url`
- `--user`
- `--password`


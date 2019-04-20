#!/usr/bin/env bash
set -Eeuxo pipefail

sudo rm -r ~/Desktop
ln -s ~/Dropbox/Desktop ~/.

sudo rm -r ~/Documents
ln -s ~/Dropbox/Documents ~/.

sudo killAll Finder

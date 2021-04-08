# koopa 🐢

Shell bootloader for bioinformatics.

Refer to the [koopa website](https://koopa.acidgenomics.com/) for installation instructions and usage details.

## `main` branch rename

We renamed the default branch from `master` to `main` on 2021-04-08.
If you have installed koopa preivously, run this code to update the default branch:

```sh
git branch -m master main
git fetch origin
git branch -u origin/main main
git remote set-head origin -a
```

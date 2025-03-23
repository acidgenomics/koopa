# Conda configuration

Updated 2024-07-15.

Alternate default channels configuration:

```yaml
channels:
  - conda-forge
  - bioconda
  - defaults
```

Useful debugging commands:

```sh
conda config --json --show
conda config --json --show-sources
```

See also:

- [How to use condarc](https://conda.io/projects/conda/en/latest/user-guide/configuration/use-condarc.html)
- [Admin multi-user install](https://docs.conda.io/projects/conda/en/latest/user-guide/configuration/admin-multi-user-install.html)
- [Manging conda](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-conda.html)
- [Conda configuration](https://docs.conda.io/projects/conda/en/latest/configuration.html)
- [Bioconda channel setup](https://bioconda.github.io/#set-up-channels)

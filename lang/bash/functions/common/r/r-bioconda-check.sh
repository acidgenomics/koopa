#!/usr/bin/env bash

# FIXME This will currently create conda packages in our cache...need to rethink
# Use our koopa variant for conda environent creation instead.

# FIXME Use a single tmpdir, so we can set a single package cache, rather than
# doing this for all packages.

koopa_r_bioconda_check() {
    # """
    # Acid Genomics Bioconda recipe 'R CMD check' workflow.
    # @note Updated 2023-09-15.
    #
    # To test against stable code, use 'archive/HEAD.tar.gz'.
    #
    # @examples
    # koopa_r_bioconda_check 'AcidGenomes' 'pipette'
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['conda']="$(koopa_locate_conda)"
    koopa_assert_is_executable "${app[@]}"
    for pkg in "$@"
    do
        local -A dict
        dict['pkg']="$pkg"
        dict['pkg2']="r-$(koopa_lowercase "${dict['pkg']}")"
        dict['tmp_dir']="$(koopa_tmp_dir)"
        dict['tarball']="https://github.com/acidgenomics/\
r-${dict['pkg2']}/archive/refs/heads/develop.tar.gz"
        dict['conda_name']="${dict['pkg2']}"
        dict['conda_prefix']="$(koopa_init_dir "${dict['tmp_dir']}/conda")"
        dict['rscript']='check.R'
        dict['tarball']="https://github.com/acidgenomics/${dict['pkg2']}/\
archive/refs/heads/develop.tar.gz"
        koopa_alert "Checking '${dict['pkg']}' package in '${dict['tmp_dir']}'."
        (
            local -A app2
            koopa_cd "${dict['tmp_dir']}"
            # FIXME We should use our koopa variant here.
            # FIXME Consider using a file instead.
            "${app['conda']}" create \
                --prefix="${dict['conda_prefix']}" \
                'r-biocmanager' \
                'r-desc' \
                'r-goalie' \
                'r-knitr' \
                'r-rcmdcheck' \
                'r-rmarkdown' \
                'r-testthat' \
                'r-urlchecker' \
                "${dict['conda_name']}"
            app2['rscript']="${dict['conda_prefix']}/bin/Rscript"
            koopa_assert_is_executable "${app2[@]}"
            koopa_download "${dict['tarball']}"
            koopa_extract "$(koopa_basename "${dict['tarball']}")" 'src'
            # FIXME Use our string writer instead.
            "${app['cat']}" << END > "${dict['rscript']}"
pkgbuild::check_build_tools(debug = TRUE)
install.packages(
    pkgs = c("AcidDevTools", "AcidTest"),
    repos = c(
        "https://r.acidgenomics.com",
        BiocManager::repositories()
    ),
    dependencies = FALSE
)
AcidDevTools::check("src")
END
            koopa_conda_activate_env "${dict['conda_prefix']}"
            "${app2['rscript']}" "${dict['rscript']}"
            koopa_conda_deactivate
        )
        koopa_rm "${dict['tmp_dir']}"
    done
    return 0
}

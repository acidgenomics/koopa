#!/usr/bin/env bash

# FIXME Consider installing packages into an isolated library, for higher
# stringency. This can help us identify issues related to 'Suggests' usage.

koopa_r_check() {
    # """
    # Acid Genomics 'R CMD check' workflow.
    # @note Updated 2023-08-15.
    #
    # @examples
    # koopa_r_check 'goalie' 'syntactic'
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['rscript']="$(koopa_locate_rscript --only-system)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    for pkg in "$@"
    do
        local -A dict
        dict['pkg']="${1:?}"
        dict['pkg2']="$(koopa_lowercase "${dict['pkg']}")"
        dict['rscript']='check.R'
        dict['tmp_dir']="$(koopa_tmp_dir)"
        dict['tarball']="https://github.com/acidgenomics/\
r-${dict['pkg2']}/archive/HEAD.tar.gz"
        (
            koopa_alert "Checking '${dict['pkg']}' package in \
'${dict['tmp_dir']}'."
            koopa_cd "${dict['tmp_dir']}"
            koopa_download "${dict['tarball']}" 'src.tar.gz'
            koopa_extract 'src.tar.gz' 'src'
            "${app['cat']}" << END > "${dict['rscript']}"
## Install BiocManager.
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}
## Install AcidDevTools.
if (!requireNamespace("AcidDevTools", quietly = TRUE)) {
    install.packages(
        pkgs = "AcidDevTools",
        repos = c(
            "https://r.acidgenomics.com",
            BiocManager::repositories()
        ),
        dependencies = TRUE
    )
}
## Install ${dict['pkg']}.
if (!requireNamespace("${dict['pkg']}", quietly = TRUE)) {
    install.packages(
        pkgs = "${dict['pkg']}",
        repos = c(
            "https://r.acidgenomics.com",
            BiocManager::repositories()
        ),
        dependencies = TRUE
    )
}
## Run package checks.
AcidDevTools::check("src")
END
            "${app['rscript']}" "${dict['rscript']}"
        )
        koopa_rm "${dict['tmp_dir']}"
    done
    return 0
}

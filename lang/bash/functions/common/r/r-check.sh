#!/usr/bin/env bash

koopa_r_check() {
    # """
    # Acid Genomics 'R CMD check' workflow.
    # @note Updated 2023-09-15.
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
        dict['pkg']="$pkg"
        dict['pkg2']="$(koopa_lowercase "${dict['pkg']}")"
        dict['rscript']='check.R'
        dict['tmp_dir']="$(koopa_tmp_dir)"
        dict['tmp_lib']="$(koopa_init_dir "${dict['tmp_dir']}/lib")"
        # To test against stable code, use 'archive/HEAD.tar.gz'.
        dict['tarball']="https://github.com/acidgenomics/\
r-${dict['pkg2']}/archive/refs/heads/develop.tar.gz"
        (
            koopa_alert "Checking '${dict['pkg']}' package in \
'${dict['tmp_dir']}'."
            koopa_cd "${dict['tmp_dir']}"
            koopa_download "${dict['tarball']}" 'src.tar.gz'
            koopa_extract 'src.tar.gz' 'src'
            "${app['cat']}" << END > "${dict['rscript']}"
.libPaths(new = "${dict['tmp_lib']}", include.site = FALSE)
message("repos")
print(getOption("repos"))
message(".libPaths")
print(.libPaths())
message("Installing AcidDevTools.")
if (!requireNamespace("BiocManager", quietly = TRUE)) {
    install.packages("BiocManager")
}
if (!requireNamespace("AcidDevTools", quietly = TRUE)) {
    install.packages(
        pkgs = c(
            "AcidDevTools",
            "desc",
            "goalie",
            "rcmdcheck",
            "testthat",
            "urlchecker"
        ),
        repos = c(
            "https://r.acidgenomics.com",
            BiocManager::repositories()
        ),
        dependencies = NA
    )
}
message("Installing ${dict['pkg']}.")
install.packages(
    pkgs = "${dict['pkg']}",
    repos = c(
        "https://r.acidgenomics.com",
        BiocManager::repositories()
    ),
    dependencies = TRUE
)
AcidDevTools::check("src")
END
            "${app['rscript']}" "${dict['rscript']}"
        )
        koopa_rm "${dict['tmp_dir']}"
    done
    return 0
}

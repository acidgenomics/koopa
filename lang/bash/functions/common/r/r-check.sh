#!/usr/bin/env bash

koopa_r_check() {
    # """
    # Acid Genomics 'R CMD check' workflow.
    # @note Updated 2023-09-15.
    #
    # To test against stable code, use 'archive/HEAD.tar.gz'.
    #
    # @examples
    # koopa_r_check 'AcidGenomes' 'pipette'
    # """
    local -A app
    koopa_assert_has_args "$#"
    app['rscript']="$(koopa_locate_rscript --only-system)"
    koopa_assert_is_executable "${app[@]}"
    for pkg in "$@"
    do
        local -A dict
        dict['pkg']="$pkg"
        dict['pkg2']="r-$(koopa_lowercase "${dict['pkg']}")"
        dict['tmp_dir']="$(koopa_tmp_dir)"
        dict['tmp_lib']="$(koopa_init_dir "${dict['tmp_dir']}/lib")"
        dict['tarball']="https://github.com/acidgenomics/\
${dict['pkg2']}/archive/refs/heads/develop.tar.gz"
        dict['rscript']="${dict['tmp_dir']}/check.R"
        read -r -d '' "dict[rscript_string]" << END || true
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
        koopa_write_string \
            --file="${dict['rscript']}" \
            --string="${dict['rscript_string']}"
        koopa_alert "Checking '${dict['pkg']}' package in '${dict['tmp_dir']}'."
        (
            koopa_cd "${dict['tmp_dir']}"
            koopa_download "${dict['tarball']}"
            koopa_extract "$(koopa_basename "${dict['tarball']}")" 'src'
            "${app['rscript']}" "${dict['rscript']}"
        )
        koopa_rm "${dict['tmp_dir']}"
    done
    return 0
}

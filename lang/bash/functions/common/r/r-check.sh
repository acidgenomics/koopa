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
    local -A dict
    local pkg
    koopa_assert_has_args "$#"
    app['rscript']="$(koopa_locate_rscript --only-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['tmp_dir']="$(koopa_tmp_dir)"
    for pkg in "$@"
    do
        local -A dict2
        dict2['pkg']="$pkg"
        dict2['pkg2']="r-$(koopa_lowercase "${dict2['pkg']}")"
        dict2['tmp_dir']="$( \
            koopa_init_dir "${dict['tmp_dir']}/${dict2['pkg2']}" \
        )"
        dict2['tmp_lib']="$(koopa_init_dir "${dict2['tmp_dir']}/lib")"
        dict2['tarball']="https://github.com/acidgenomics/\
${dict2['pkg2']}/archive/refs/heads/develop.tar.gz"
        dict2['rscript']="${dict2['tmp_dir']}/check.R"
        read -r -d '' "dict2[rscript_string]" << END || true
.libPaths(new = "${dict2['tmp_lib']}", include.site = FALSE)
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
message("Installing ${dict2['pkg']}.")
install.packages(
    pkgs = "${dict2['pkg']}",
    repos = c(
        "https://r.acidgenomics.com",
        BiocManager::repositories()
    ),
    dependencies = TRUE
)
AcidDevTools::check("src")
END
        koopa_write_string \
            --file="${dict2['rscript']}" \
            --string="${dict2['rscript_string']}"
        koopa_alert "Checking '${dict2['pkg']}' in '${dict2['tmp_dir']}'."
        (
            koopa_cd "${dict2['tmp_dir']}"
            koopa_download "${dict2['tarball']}"
            koopa_extract "$(koopa_basename "${dict2['tarball']}")" 'src'
            "${app['rscript']}" "${dict2['rscript']}"
        )
    done
    koopa_rm "${dict['tmp_dir']}"
    return 0
}

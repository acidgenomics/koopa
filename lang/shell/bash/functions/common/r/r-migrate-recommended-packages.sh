#!/usr/bin/env bash

koopa_r_migrate_recommended_packages() {
    # """
    # Migrate recommended R packages from 'library' to 'site-library'.
    # @note Updated 2022-09-13.
    #
    # Currently includes these packages: KernSmooth, MASS, Matrix, boot, class,
    # cluster, codetools, foreign, lattice, mgcv, nlme, nnet, rpart, spatial,
    # survival.
    # """
    # FIXME AcidDevTools::migrateRecommendedPackages
    # FIXME Need to update R package library permissions
    # FIXME Need to call this as sudo for system R.
    # In this case, need to update R package permissions.
    # FIXME Check to see if specific recommended package is installed in system
    # library (e.g. MASS, KernSmooth, codetools).
    return 0
}

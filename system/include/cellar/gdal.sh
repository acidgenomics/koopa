#!/usr/bin/env bash

# Install GDAL.
# Updated 2019-07-26.

# See also:
# - https://gdal.org/
# - https://github.com/OSGeo/GDAL

# Set `--with-proj` flag if you hit "PROJ 6 symbols not found" error.
# https://github.com/OSGeo/gdal/issues/1352
# FIXME This still isn't working correctly, due to ldconfig issue.
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_alter_name'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `H5P_CLS_DATASET_CREATE_ID_g'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_eckert_i'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_miller_cylindrical'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_trans_generic'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_oblique_stereographic'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_wagner_i'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_get_geodetic_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_as_wkt'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_projected_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_area_of_use'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_compound_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_hotine_oblique_mercator_two_point_natural                  _origin'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_grid_info'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_transverse_mercator'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_cs_get_type'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_errno_string'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_utm'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_info'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_eckert_iii'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_equidistant_conic'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_coordoperation_get_method_info'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_mercator_variant_a'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_non_deprecated'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_international_map_world_polyconic'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_azimuthal_equidistant'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_create_bound_crs_to_WGS84'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_geostationary_satellite_sweep_y'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_eckert_vi'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_geographic_crs_from_datum'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_two_point_equidistant'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_wagner_iii'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_ellipsoidal_2D_cs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `H5free_memory'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_context_use_proj4_init_rules'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_sinusoidal'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_goode_homolosine'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_eckert_v'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_destroy'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_identify'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_quadrilateralized_spherical_cube'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_trans'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_cartesian_2D_cs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_transverse_mercator_south_oriented'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_engineering_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_hotine_oblique_mercator_variant_a'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_operations'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_operation_factory_context_set_area_of_interest'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_orthographic'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_eckert_iv'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_list_get_count'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_context_set_search_paths'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_from_name'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_ellipsoid_get_parameters'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_wagner_ii'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `H5P_CLS_FILE_ACCESS_ID_g'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_albers_equal_area'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_polar_stereographic_variant_a'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_wagner_vii'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_alter_cs_linear_unit'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_lambert_conic_conformal_2sp_belgium'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_stereographic'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_mercator_variant_b'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_context_destroy'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_crs_info_list_from_database'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_source_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_van_der_grinten'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_robinson'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_context_errno'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_new_zealand_mapping_grid'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_ellipsoid'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_is_deprecated'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_prime_meridian_get_parameters'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_gnomonic'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_mollweide'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_coordoperation_get_towgs84_values'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_alter_parameters_linear_unit'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_gauss_schreiber_transverse_mercator'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_transformation'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_codes_from_database'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_laborde_oblique_mercator'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_get_datum'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_wagner_iv'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_lambert_cylindrical_equal_area'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_type'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_geocentric_crs_from_datum'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_int_list_destroy'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_eckert_ii'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_list_get'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_assign_context'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_query_geodetic_crs_from_datum'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_alter_cs_angular_unit'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_convert_conversion_to_other_method'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_geographic_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_clone'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_is_equivalent_to'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_id_code'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_lambert_azimuthal_equal_area'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_log_func'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_create_bound_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_cs_get_axis_count'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_authorities_from_database'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_name'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_gall'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_krovak_north_oriented'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_cassini_soldner'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_info_list_destroy'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_spherical_cross_track_height'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_get_coordoperation'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_lambert_conic_conformal_1sp'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_as_proj_string'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_geocentric_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_from_wkt'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_coordoperation_get_param'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_cs_get_axis_info'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_target_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_uom_get_info_from_database'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_operation_factory_context_set_grid_availability_use'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_operation_factory_context'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_list_destroy'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_interrupted_goode_homolosine'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_hotine_oblique_mercator_variant_b'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_prime_meridian'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_polar_stereographic_variant_b'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_american_polyconic'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_string_list_destroy'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_operation_factory_context_set_spatial_criterion'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_wagner_v'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_operation_factory_context_destroy'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_vertical_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_bonne'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_crs_to_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_lambert_conic_conformal_2sp'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_alter_geodetic_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_get_id_auth_name'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_alter_id'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_tunisia_mapping_grid'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_equidistant_cylindrical'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_from_database'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_context_create'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_get_sub_crs'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_crs_get_coordinate_system'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_create_conversion_wagner_vi'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_coordoperation_get_param_index'
# gdal-3.0.1/.libs/libgdal.so: undefined reference to `proj_coordoperation_get_param_count'
# collect2: error: ld returned 1 exit status


_koopa_assert_has_no_environments

# Note that this script requires PROJ 6.
_koopa_assert_is_installed proj

name="gdal"
version="$(koopa variable "$name")"
prefix="$(koopa cellar-prefix)/${name}/${version}"
build_prefix="$(koopa build-prefix)"
tmp_dir="$(koopa tmp-dir)/${name}"
build_os_string="$(koopa build-os-string)"
exe_file="${prefix}/bin/${name}"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/${name}/releases/download/v${version}/${file}"
    wget "$url"
    tar -xzvf "$file"
    cd "${name}-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix" \
        --with-proj="$build_prefix"
    make
    make test
    make install
    rm -rf "$tmp_dir"
)

link-cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"

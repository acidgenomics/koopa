# HMS RC modules
# 2017-06-29
#
# Check loaded modules:
# `module list`
#
# Unload everything:
# `module load null`
#
# Check available modules:
# - `module avail`
# - `module avail stats/R`
if [[ $HPC == "HMS RC O2" ]]; then
    # priority
    module load gcc/6.2.0
    module load harfbuzz/1.3.4
    # alphabetical
    module load bcl2fastq/2.18.0.12
    # module load boost/1.62.0
    # module load cairo/1.14.6
    # module load cmake/3.7.1
    # module load fontconfig/2.12.1
    # module load freetype/2.7
    # module load hdf5/1.10.1
    # module load ImageMagick/6.9.1.10
    module load java/jdk-1.8u112
    module load openblas/0.2.19
    # module load python/3.6.0
    # module load R/3.4.1
    module load sratoolkit/2.8.1
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    # priority
    module load dev/compiler/gcc-4.8.5
    module load utils/harfbuzz/1.2.3
    # alphabetical
    # module load dev/boost-1.57.0
    # module load dev/compiler/cmake-3.3.1
    # module load dev/lapack
    # module load dev/leiningen/stable-feb032016
    # module load dev/openblas/0.2.14
    # module load dev/python/3.4.2
    # module load dev/ruby/2.2.4
    # module load image/imageMagick/6.9.1
    module load seq/bcl2fastq/2.17.1.14
    # module load seq/cellranger/2.0.0
    # module load seq/sratoolkit/2.8.1-3
    # module load utils/cairo/1.14.2
    # module load utils/fontconfig/2.11.1
    # module load utils/freetype/2.6
    # module load utils/hdf5/1.8.16
    # module load utils/texlive/2015
fi

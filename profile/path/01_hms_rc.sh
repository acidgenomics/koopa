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
    module load \
        bcl2fastq/2.18.0.12 \
        boost/1.62.0 \
        cairo/1.14.6 \
        cmake/3.7.1 \
        fontconfig/2.12.1 \
        freetype/2.7 \
        gcc/6.2.0 \
        hdf5/1.10.1 \
        ImageMagick/6.9.1.10 \
        openblas/0.2.19 \
        python/3.6.0 \
        R/3.4.1 \
        sratoolkit/2.8.1
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    module load \
        dev/boost-1.57.0 \
        dev/compiler/cmake-3.3.1 \
        dev/compiler/gcc-4.8.5 \
        dev/lapack \
        dev/leiningen/stable-feb032016 \
        dev/openblas/0.2.14 \
        dev/python/3.4.2 \
        dev/ruby/2.2.4 \
        image/imageMagick/6.9.1 \
        seq/bcl2fastq/2.17.1.14 \
        seq/cellranger/2.0.0 \
        seq/sratoolkit/2.8.1-3 \
        stats/R/3.3.1 \
        utils/cairo/1.14.2 \
        utils/fontconfig/2.11.1 \
        utils/freetype/2.6 \
        utils/hdf5/1.8.16
fi

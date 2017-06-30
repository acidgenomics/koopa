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
        gcc/6.2.0 \
        hdf5/1.10.1 \
        ImageMagick/6.9.1.10 \
        python/3.6.0 \
        R/3.3.3 \
        samtools/1.3.1 \
        sratoolkit/2.8.1 \
        xz/5.2.3
elif [[ $HPC == "HMS RC Orchestra" ]]; then
    module load \
        dev/boost-1.57.0 \
        dev/compiler/cmake-3.3.1 \
        dev/compiler/gcc-4.8.5 \
        dev/lapack \
        dev/leiningen/stable-feb032016 \
        dev/openblas/0.2.14 \
        dev/openssl/1.0.1 \
        dev/python/3.4.2 \
        dev/ruby/2.2.4 \
        image/imageMagick/6.9.1 \
        seq/bcl2fastq/2.17.1.14 \
        seq/cellranger/2.0.0 \
        seq/samtools/1.3 \
        seq/sratoolkit/2.8.1-3 \
        stats/R/3.3.1 \
        utils/hdf5/1.8.16 \
        utils/pandoc/1.17.0.3 \
        utils/xz/5.2.2
fi

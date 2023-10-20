#!/usr/bin/env bash

# FIXME Need to add support for this.
#
# Recommended defaults:
# https://github.com/bcbio/bcbio-nextgen/blob/master/bcbio/rnaseq/rsem.py
#
# works only in unstranded mode for now (--forward-prob 0.5)
#
#CALCULATE_EXP = (
#    "rsem-calculate-expression --bam {core_flag} {paired_flag} "
#    "--no-bam-output --forward-prob 0.5 "
#    "--estimate-rspd {bam_file} {rsem_genome_dir}/{build} {samplename}")
#
#paired_flag = "--paired" if bam.is_paired(bam_file) else ""
#    core_flag = "-p {cores}".format(cores=cores)
#    command = CALCULATE_EXP.format(
#        core_flag=core_flag, paired_flag=paired_flag, bam_file=bam_file,
#        rsem_genome_dir=rsem_genome_dir, build=build, samplename=samplename)
#    message = "Calculating transcript expression of {bam_file} using RSEM."#

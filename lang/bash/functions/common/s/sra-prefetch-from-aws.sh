#!/usr/bin/env bash

# FIXME Use parallel to speed this up.

koopa_sra_prefetch_from_aws() {
    # """
    # Prefetch files from SRA on AWS.
    # @note Updated 2023-11-07.
    #
    # @seealso
    # - https://davetang.org/muse/2023/04/06/
    #     til-that-you-can-download-sra-data-from-aws/
    # - https://github.com/davetang/research_parasite
    # - https://www.gnu.org/software/parallel/man.html
    # """
    s3_uri="s3://sra-pub-run-odp.s3.amazonaws.com/sra/<SRR_ID>/<SRR_ID>"
    # FIXME Use aws s3 sync s3_uri XXX to complete.
    return 0
}

#!/usr/bin/env bash

koopa_aws_s3_delete_versioned_glacier_objects() {
    # """
    # Delete all non-canonical versioned glacier objects for an S3 bucket.
    # @note Updated 2025-05-08.
    #
    # @examples
    # > koopa_aws_s3_delete_versioned_glacier_objects \
    # >     --bucket='example-bucket' \
    # >     --dry-run \
    # >     --profile='default' \
    # >     --region='us-east-1'
    # """
    koopa_aws_s3_delete_versioned_objects --glacier "$@"
}

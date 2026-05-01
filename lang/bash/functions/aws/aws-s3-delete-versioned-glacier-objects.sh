#!/usr/bin/env bash

_koopa_aws_s3_delete_versioned_glacier_objects() {
    # """
    # Delete all non-canonical versioned glacier objects for an S3 bucket.
    # @note Updated 2025-05-08.
    #
    # @examples
    # > _koopa_aws_s3_delete_versioned_glacier_objects \
    # >     --bucket='example-bucket' \
    # >     --dry-run \
    # >     --profile='default' \
    # >     --region='us-east-1'
    # """
    _koopa_aws_s3_delete_versioned_objects --glacier "$@"
}

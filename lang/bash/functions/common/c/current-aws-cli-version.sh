#!/usr/bin/env bash

koopa_current_aws_cli_version() {
    # """
    # Get the current AWS CLI version.
    # @note Updated 2023-12-22.
    # """
    koopa_current_github_tag_version 'aws/aws-cli'
    return 0
}

#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install AWS CLI binary.
    # @note Updated 2022-04-09.
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     getting-started-install.html
    # - https://github.com/awsdocs/aws-cli-user-guide/blob/main/doc_source/
    #     install-cliv2-mac.md
    # """
    local app dict
    declare -A app=(
        [cat]="$(koopa_locate_cat)"
        [installer]="$(koopa_macos_locate_installer)"
    )
    declare -A dict=(
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
        [xml_file]='choices.xml'
    )
    dict[libexec_prefix]="${dict[prefix]}/libexec"
    koopa_mkdir "${dict[libexec_prefix]}"
    dict[maj_ver]="$(koopa_major_version "${dict[version]}")"
    dict[file]="AWSCLIV${dict[maj_ver]}-${dict[version]}.pkg"
    dict[url]="https://awscli.amazonaws.com/${dict[file]}"
    koopa_download "${dict[url]}" "${dict[file]}"
    "${app[cat]}" > "${dict[xml_file]}" << END
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <array>
   <dict>
      <key>choiceAttribute</key>
      <string>customLocation</string>
      <key>attributeSetting</key>
      <string>${dict[libexec_prefix]}</string>
      <key>choiceIdentifier</key>
      <string>default</string>
    </dict>
  </array>
</plist>
END
    "${app[installer]}" \
        -pkg "${dict[file]}" \
        -target 'CurrentUserHomeDirectory' \
        -applyChoiceChangesXML "${dict[xml_file]}" \
        > /dev/null
    koopa_ln \
        "${dict[libexec_prefix]}/aws-cli/aws" \
        "${dict[prefix]}/bin/aws"
    koopa_ln \
        "${dict[libexec_prefix]}/aws-cli/aws_completer" \
        "${dict[prefix]}/bin/aws_completer"
    return 0
}

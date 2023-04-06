#!/usr/bin/env bash

# NOTE This is causing shell to exit when bash is installed at /usr/local.

main() {
    local -A app
    local -a files
    app['bash']="$(koopa_locate_bash)"
    koopa_assert_is_executable "${app[@]}"
    files=(
        '/usr/local/bin/bash'
        '/usr/local/bin/bashbug'
        '/usr/local/include/bash'
        '/usr/local/lib/bash'
        '/usr/local/pkgconfig/bash.pc'
        '/usr/local/share/doc/bash'
        '/usr/local/share/info/bash.info'
        '/usr/local/share/locale/af/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/bg/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/ca/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/cs/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/da/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/de/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/el/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/en@boldquot/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/en@quot/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/eo/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/es/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/et/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/fi/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/fr/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/ga/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/gl/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/hr/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/hu/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/id/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/it/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/ja/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/ko/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/lt/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/nb/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/nl/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/pl/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/pt/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/pt_BR/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/ro/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/ru/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/sk/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/sl/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/sr/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/sv/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/tr/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/uk/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/vi/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/zh_CN/LC_MESSAGES/bash.mo'
        '/usr/local/share/locale/zh_TW/LC_MESSAGES/bash.mo'
        '/usr/local/share/man/man1/bash.1'
        '/usr/local/share/man/man1/bashbug.1'
    )
    koopa_rm --sudo "${files[@]}"
    return 0
}

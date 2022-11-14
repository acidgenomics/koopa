#!/usr/bin/env bash

# FIXME This currently doesn't harden Perl correctly...
# ❯ agat --version
# Can't locate AGAT/AppEaser.pm in @INC (you may need to install the AGAT::AppEaser module) (@INC contains: /opt/koopa/app/perl/5.36.0/lib/site_perl/5.36.0/darwin-2level /opt/koopa/app/perl/5.36.0/lib/site_perl/5.36.0 /opt/koopa/app/perl/5.36.0/lib/5.36.0/darwin-2level /opt/koopa/app/perl/5.36.0/lib/5.36.0) at /opt/koopa/bin/agat line 8.
# BEGIN failed--compilation aborted at /opt/koopa/bin/agat line 8.

main() {
    koopa_install_app_subshell \
        --installer='conda-env' \
        --name='agat' \
        "$@"
}

#!/bin/ssh

# Detect specific instances by the hostname.

case "$(uname -n)" in
                 azlabapp) export AZURE=1;;
       rc.fas.harvard.edu) export HARVARD_ODYSSEY=1;;
    o2.rc.hms.harvard.edu) export HARVARD_O2=1;;
                        *) ;;
esac


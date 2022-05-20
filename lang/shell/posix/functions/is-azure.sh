#!/bin/sh

koopa_is_azure() {
    # """
    # Is the current session running on Microsoft Azure?
    # @note Updated 2020-08-06.
    # """
    koopa_is_host 'azure'
}

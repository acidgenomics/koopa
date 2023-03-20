#!/usr/bin/env bash

# NOTE macOS segfault debugging:
#
# - https://developer.apple.com/forums/thread/719949
# - https://github.com/Homebrew/homebrew-core/issues/116415
# - https://github.com/aws/aws-sdk-pandas/issues/1774
# - https://github.com/invoke-ai/InvokeAI/pull/1969
#
# Thread 0 Crashed::  Dispatch queue: com.apple.main-thread
# 0   libarrow.600.dylib            	       0x12197f162 Aws::Http::CurlHandleContainer::~CurlHandleContainer() + 50
# 1   libarrow.600.dylib            	       0x12197b64a Aws::Http::CurlHttpClient::~CurlHttpClient() + 186
# 2   libarrow.600.dylib            	       0x1219dbc6b Aws::Internal::AWSHttpResourceClient::~AWSHttpResourceClient() + 139
# 3   libarrow.600.dylib            	       0x12069f161 arrow::Future<arrow::internal::Empty>::~Future() + 49
# 4   libsystem_c.dylib             	    0x7ff800f9ac1f __cxa_finalize_ranges + 409
# 5   libsystem_c.dylib             	    0x7ff800f9aa39 exit + 35
# 6   Python                        	       0x10aec350e Py_Exit + 30
# 7   Python                        	       0x10aec7b43 handle_system_exit + 35
# 8   Python                        	       0x10aec74da _PyErr_PrintEx + 42
# 9   Python                        	       0x10aec6ab9 pyrun_simple_file + 761
# 10  Python                        	       0x10aec6770 PyRun_SimpleFileExFlags + 112
# 11  Python                        	       0x10aeea56a pymain_run_file + 362
# 12  Python                        	       0x10aee9cb1 Py_RunMain + 2225
# 13  Python                        	       0x10aeeb7ea Py_BytesMain + 42
# 14  dyld                          	    0x7ff800d71310 start + 2432
#
# Thread 1:
# 0   libsystem_pthread.dylib       	    0x7ff80109fc58 start_wqthread + 0

main() {
    koopa_install_app_subshell \
        --installer='python-venv' \
        --name='latch' \
        -D --python-version='3.10' \
        "$@"
}

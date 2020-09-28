#!/usr/bin/env bash

# Copyright The Helm Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail
# set -x

export SCRIPT_DIR=$(dirname -- "$(readlink -f "${BASH_SOURCE[0]}" || realpath "${BASH_SOURCE[0]}")")

if [ -z "$VERSION" ]; then
    echo "ERROR: environment variable VERSION is not set"
    exit 1
fi

main() {

    if [[ -z "${INPUT_ACTION}" ]]; then
        "$SCRIPT_DIR/package.sh"
        "$SCRIPT_DIR/test.sh"
        "$SCRIPT_DIR/publish.sh"
    elif [[ "${INPUT_ACTION}" == "package_and_test" ]]; then
        "$SCRIPT_DIR/package.sh"
        "$SCRIPT_DIR/test.sh"
    else
        "$SCRIPT_DIR/$INPUT_ACTION.sh"
    fi

}

main

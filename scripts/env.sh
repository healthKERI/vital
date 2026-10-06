#!/bin/bash

scripts=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export VITAL_SCRIPT_DIR="${scripts}"
VITAL_REPO_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. &> /dev/null && pwd )
#!/bin/bash

set -xe

source $(dirname "$0")/tc-tests-utils.sh

nodever=$1
aot_model=$2

if [ -z "${nodever}" ]; then
    echo "No node version given, aborting."
    exit 1
fi;

download_material "/tmp/ds-lib" "${aot_model}"

phrase=""

pushd ${HOME}/DeepSpeech/ds/native_client/
    node --version
    npm --version
    if [ "${aot_model}" = "--aot" ]; then
        npm install ${DEEPSPEECH_AOT_ARTIFACTS_ROOT}/deepspeech-0.0.1.tgz
    else
        npm install ${DEEPSPEECH_ARTIFACTS_ROOT}/deepspeech-0.0.1.tgz
    fi

    npm install

    phrase_pbmodel_nolm=$(LD_LIBRARY_PATH=/tmp/ds-lib/:$LD_LIBRARY_PATH node client.js /tmp/${model_name} /tmp/LDC93S1.wav /tmp/alphabet.txt)
    assert_correct_ldc93s1 "${phrase_pbmodel_nolm}"

    phrase_pbmodel_withlm=$(LD_LIBRARY_PATH=/tmp/ds-lib/:$LD_LIBRARY_PATH node client.js /tmp/${model_name} /tmp/LDC93S1.wav /tmp/alphabet.txt /tmp/lm.binary /tmp/trie)
    assert_correct_ldc93s1 "${phrase_pbmodel_withlm}"

    if [ "${aot_model}" = "--aot" ]; then
        phrase_somodel_nolm=$(LD_LIBRARY_PATH=/tmp/ds-lib/:$LD_LIBRARY_PATH node client.js "" /tmp/LDC93S1.wav /tmp/alphabet.txt)
        phrase_somodel_withlm=$(LD_LIBRARY_PATH=/tmp/ds-lib/:$LD_LIBRARY_PATH node client.js "" /tmp/LDC93S1.wav /tmp/alphabet.txt /tmp/lm.binary /tmp/trie)

        assert_correct_ldc93s1_somodel "${phrase_somodel_nolm}" "${phrase_somodel_withlm}"
    fi
popd

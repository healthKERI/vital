#!/bin/bash

# To run this script you need to run the following command in a separate terminals:
#   > kli witness demo


# Schema SAIDs - from ./schema and ./schema/GLEIF
QVI_SCHEMA_SAID="EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao"
LE_SCHEMA_SAID="ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY"
LE_SUBUNIT_SCHEMA_SAID="EP1jGIb7KXotuUZJf1NSu5wQ089epFfv93cpZECj-YBs"
LESR_AUTH_SCHEMA_SAID="ECoqb1jxC9f9zwh664stMAy6gpnNduvP_3SCQlLvkPAR"
LESR_SCHEMA_SAID="EHfJ563sbivepFRzk506fJenWIeVG2uXdAes8iJhHJan"

SALTS=(
  "0ABlVhotBlg6uiSp-ZKFJXiV"
  "0ADs6PksRhqw9d6ttuxXO81I"
  "0ABhUB3WkABnbf0uM4VIMbh5"
  "0ADDe_PPZtX1yZCwvWzFORBo"
  "0AAZQ-pe4gkNQkWd4YeqV8Lu"
  "0AC9vSlGVf7yeI2qszN7Jrys"
  "0AAHdyYoLKvCz-2t8rZntvIY"
  "0ABgVVa5_JWD9aA7cCgkK4LS"
  "0ABTe-MzPmsr9NsdaGD5x1RH"
  "0ABffuRtsC3GECKCIoEWkUXw"
  "0ADN3WLAtqB8iIVeU6PmVe0B"
  "0ADn61HcLQN8myd6NN9veFY_"
  "0AAfx-L7mvA16T28sn26R-Fp"
  "0ACAU54EihaqKd5DVtWbrGuB"
  "0ACJXo370D1KB-Sz1qRJG2ih"
  "0AAYLUNlLt_K_h9TsSiSh_KP"
  "0AAV1HCMcTiqKf4LNPhMZdT5"
  "0ACUPCawV1zvtA8UE8RP1GrO"
  "0ABOLE_aKPqeMA21QXrQfdyD"
  "0AApZ9hDSiseQ46NpuOeD7Xf"
)

for i in {1..20}; do
  kli init --name "ACME Health-$i" --salt "${SALTS[$i-1]}" --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-oobis-schema
  kli incept --name "ACME Health-$i" --alias "ACME Health" --file ${VITAL_SCRIPT_DIR}/data/simple-aid.json
  kli incept --name "ACME Health-$i" --alias "healthKERI" --file ${VITAL_SCRIPT_DIR}/data/simple-aid.json
done


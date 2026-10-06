#!/bin/bash

# To run this script you need to run the following command in a separate terminals:
#   > kli witness demo


# Schema SAIDs - from ./schema and ./schema/GLEIF
QVI_SCHEMA_SAID="EBfdlu8R27Fbx-ehrqwImnK-8Cm79sqbAQ4MmvEAYqao"
LE_SCHEMA_SAID="ENPXp1vQzRF6JwIuS-mp2U8Uf1MoADoP_GqQ62VsDZWY"
LE_SUBUNIT_SCHEMA_SAID="EP1jGIb7KXotuUZJf1NSu5wQ089epFfv93cpZECj-YBs"
LESR_AUTH_SCHEMA_SAID="ECoqb1jxC9f9zwh664stMAy6gpnNduvP_3SCQlLvkPAR"
LESR_SCHEMA_SAID="EHfJ563sbivepFRzk506fJenWIeVG2uXdAes8iJhHJan"

# EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R
kli init --name "GLEIF External" --salt 0ACDEyMzQ1Njc4OWxtbm9GhI --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name "GLEIF External" --alias "GLEIF External" --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
EXTERNAL_AID=$(kli aid --name "GLEIF External" --alias "GLEIF External")

# EK4IkBaWvVlkfiscv4w_cOEmGcfnbbumi_Q5fMh_HYO1
kli init --name QVI --salt 0ACDEyMzQ1Njc4OWxtbm9aBc --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name QVI --alias QVI --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
QVI_AID=$(kli aid --name QVI --alias QVI)

# "${LEGAL_ENTITY_AID}"
kli init --name "CVS Health" --salt 0ACDEyMzQ1Njc4OWxtbm9AbC --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name "CVS Health" --alias "CVS Health" --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
LEGAL_ENTITY_AID=$(kli aid --name "CVS Health" --alias "CVS Health")

# "${SUBUNIT_AID}"
kli init --name "Aetna" --salt 0ACDEyMzQ1Njc4OWxtbm9dEf --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name "Aetna" --alias "Aetna" --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
SUBUNIT_AID=$(kli aid --name "Aetna" --alias "Aetna")

echo 'resolving GLEIF External'
kli oobi resolve --name QVI --oobi-alias "GLEIF External" --oobi http://127.0.0.1:5642/oobi/EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name "CVS Health" --oobi-alias "GLEIF External" --oobi http://127.0.0.1:5642/oobi/EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name "Aetna" --oobi-alias "GLEIF External" --oobi http://127.0.0.1:5642/oobi/EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
echo 'resolving QVI'
kli oobi resolve --name "GLEIF External" --oobi-alias QVI --oobi http://127.0.0.1:5642/oobi/"${QVI_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name "CVS Health" --oobi-alias QVI --oobi http://127.0.0.1:5642/oobi/"${QVI_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name "Aetna" --oobi-alias QVI --oobi http://127.0.0.1:5642/oobi/"${QVI_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
echo 'resolving "CVS Health"'
kli oobi resolve --name "GLEIF External" --oobi-alias "CVS Health" --oobi http://127.0.0.1:5642/oobi/"${LEGAL_ENTITY_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name QVI --oobi-alias "CVS Health" --oobi http://127.0.0.1:5642/oobi/"${LEGAL_ENTITY_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name "Aetna" --oobi-alias "CVS Health" --oobi http://127.0.0.1:5642/oobi/"${LEGAL_ENTITY_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
echo 'resolving "Aetna"'
kli oobi resolve --name "GLEIF External" --oobi-alias "Aetna" --oobi http://127.0.0.1:5642/oobi/"${SUBUNIT_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name QVI --oobi-alias "Aetna" --oobi http://127.0.0.1:5642/oobi/"${SUBUNIT_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name "CVS Health" --oobi-alias "Aetna" --oobi http://127.0.0.1:5642/oobi/"${SUBUNIT_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha

kli vc registry incept --name "GLEIF External" --alias "GLEIF External" --registry-name vLEI-external
kli vc registry incept --name QVI --alias QVI --registry-name vLEI-QVI
kli vc registry incept --name QVI --alias QVI --registry-name EHfJ563sbivepFRzk506fJenWIeVG2uXdAes8iJhHJan
kli vc registry incept --name "CVS Health" --alias "CVS Health" --registry-name vLEI-legal-entity
kli vc registry incept --name "Aetna"  --alias "Aetna" --registry-name vLEI-subunit

echo -e "\nIssue QVI credential vLEI from GLEIF External to QVI"
kli vc create --name "GLEIF External" --alias "GLEIF External" --registry-name vLEI-external --schema ${QVI_SCHEMA_SAID} --recipient "${QVI_AID}" --data @${VITAL_SCRIPT_DIR}/data/qvi-data.json
QVI_SAID=$(kli vc list --name "GLEIF External" --alias "GLEIF External" --issued --said --schema ${QVI_SCHEMA_SAID})
kli ipex grant --name "GLEIF External" --alias "GLEIF External" --said "${QVI_SAID}" --recipient "${QVI_AID}"
GRANT=$(kli ipex list --name QVI --alias QVI --poll --said)
kli ipex admit --name QVI --alias QVI --said "${GRANT}"
kli vc export --name QVI --alias QVI --said "${QVI_SAID}" --full> /tmp/qvi.cesr
kli vc list --name QVI --alias QVI

echo -e "\nIssue LE credential from QVI to Legal Entity - have to create the edges first"
QVI_SAID=`kli vc list --name QVI --alias QVI --said --schema ${QVI_SCHEMA_SAID}`
echo \"$QVI_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/legal-entity-edges-filter.jq  > /tmp/legal-entity-edges.json
kli saidify --file /tmp/legal-entity-edges.json
kli vc create --name QVI --alias QVI --registry-name vLEI-QVI --schema "${LE_SCHEMA_SAID}" --recipient "${LEGAL_ENTITY_AID}" --data @${VITAL_SCRIPT_DIR}/data/legal-entity-data.json --edges @/tmp/legal-entity-edges.json --rules @${VITAL_SCRIPT_DIR}/data/rules.json
SAID=$(kli vc list --name QVI --alias QVI --issued --said --schema "${LE_SCHEMA_SAID}")
kli ipex grant --name QVI --alias QVI --said "${SAID}" --recipient "${LEGAL_ENTITY_AID}"
GRANT=$(kli ipex list --name "CVS Health" --alias "CVS Health" --poll --said)
kli ipex admit --name "CVS Health" --alias "CVS Health" --said "${GRANT}"
kli vc list --name "CVS Health" --alias "CVS Health"

echo -e "\nIssue LegalEntitySubunitvLEICredential from Legal Entity to "Aetna""
kli vc import --name "Aetna" --file /tmp/qvi.cesr --said "${QVI_SAID}"
LE_SAID=`kli vc list --name "CVS Health" --alias "CVS Health" --said --schema ${LE_SCHEMA_SAID}`
echo \"$LE_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/subunit-edges-filter.jq > /tmp/subunit-edges.json
kli saidify --file /tmp/subunit-edges.json
kli vc create --name "CVS Health" --alias "CVS Health" --registry-name vLEI-legal-entity \
  --schema ${LE_SUBUNIT_SCHEMA_SAID} \
  --recipient "${SUBUNIT_AID}" \
  --data @${VITAL_SCRIPT_DIR}/data/subunit-data.json \
  --edges @/tmp/subunit-edges.json \
  --rules @${VITAL_SCRIPT_DIR}/data/rules.json
SUBUNIT_SAID=$(kli vc list --name "CVS Health" --alias "CVS Health" --issued --said --schema ${LE_SUBUNIT_SCHEMA_SAID})
kli ipex grant --name "CVS Health" --alias "CVS Health" --said "${SUBUNIT_SAID}" --recipient "${SUBUNIT_AID}"
GRANT=$(kli ipex list --name "Aetna" --alias "Aetna" --poll --said)
kli ipex admit --name "Aetna" --alias "Aetna" --said "${GRANT}"
kli vc export --name "Aetna" --alias "Aetna" --said "${SUBUNIT_SAID}" --full> /tmp/subunit.cesr
kli vc list --name "Aetna" --alias "Aetna"

echo -e "\nIssue LESRAuthorizationvLEICredential from Legal Entity to QVI"
SUBUNIT_SAID=`kli vc list --name "Aetna" --alias "Aetna" --said --schema ${LE_SUBUNIT_SCHEMA_SAID}`
kli vc import --name QVI --file /tmp/subunit.cesr --said "${SUBUNIT_SAID}"
echo \"$SUBUNIT_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/lesr-auth-edges-filter.jq > /tmp/lesr-auth-edges.json
kli saidify --file /tmp/lesr-auth-edges.json
kli vc create --name "CVS Health" --alias "CVS Health" --registry-name vLEI-legal-entity \
  --schema ${LESR_AUTH_SCHEMA_SAID} \
  --recipient "${QVI_AID}" \
  --data @${VITAL_SCRIPT_DIR}/data/lesr-auth-data.json \
  --edges @/tmp/lesr-auth-edges.json \
  --rules @${VITAL_SCRIPT_DIR}/data/rules.json
LESR_AUTH_SAID=$(kli vc list --name "CVS Health" --alias "CVS Health" --issued --said --schema ${LESR_AUTH_SCHEMA_SAID})
kli ipex grant --name "CVS Health" --alias "CVS Health" --said "${LESR_AUTH_SAID}" --recipient "${QVI_AID}"
GRANT=$(kli ipex list --name QVI --alias QVI --poll --said | tail -1)
kli ipex admit --name QVI --alias QVI --said "${GRANT}"
kli vc export --name QVI --alias QVI --said "${LESR_AUTH_SAID}" --full> /tmp/lesr_auth.cesr
kli vc list --name QVI --alias QVI

echo -e "\nIssue LegalEntitySubunitRolevLEICredential from QVI to Subunit"
AUTH_SAID=`kli vc list --name QVI --alias QVI --said --schema ${LESR_AUTH_SCHEMA_SAID}`
echo \"$AUTH_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/lesr-edges-filter.jq > /tmp/lesr-edges.json
kli vc import --name "Aetna" --file /tmp/lesr_auth.cesr --said "${LESR_AUTH_SAID}"
kli saidify --file /tmp/lesr-edges.json
kli vc create --name QVI --alias QVI --registry-name vLEI-QVI \
  --schema ${LESR_SCHEMA_SAID} \
  --recipient "${SUBUNIT_AID}" \
  --data @${VITAL_SCRIPT_DIR}/data/lesr-data.json \
  --edges @/tmp/lesr-edges.json \
  --rules @${VITAL_SCRIPT_DIR}/data/rules.json
SAID=$(kli vc list --name QVI --alias QVI --issued --said --schema ${LESR_SCHEMA_SAID})
kli ipex grant --name QVI --alias QVI --said "${SAID}" --recipient "${SUBUNIT_AID}"
GRANT=$(kli ipex list --name "Aetna" --alias "Aetna" --poll --said | tail -1)
kli ipex admit --name "Aetna" --alias "Aetna" --said "${GRANT}"
kli vc list --name "Aetna" --alias "Aetna"

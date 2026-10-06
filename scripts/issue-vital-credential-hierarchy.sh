#!/bin/bash

# To run this script you need to run the following command in a separate terminals:
#   > kli witness demo
# and from the vLEI repo run:
#   > vLEI-server -s ./schema/acdc -c ./samples/acdc/ -o ./samples/oobis/
#

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

# "${QVI_AID}"
kli init --name qvi --salt 0ACDEyMzQ1Njc4OWxtbm9aBc --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name qvi --alias qvi --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
QVI_AID=$(kli aid --name qvi --alias qvi)

# "${LEGAL_ENTITY_AID}"
kli init --name legal-entity --salt 0ACDEyMzQ1Njc4OWxtbm9AbC --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name legal-entity --alias legal-entity --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
LEGAL_ENTITY_AID=$(kli aid --name legal-entity --alias legal-entity)

# "${SUBUNIT_AID}"
kli init --name subunit --salt 0ACDEyMzQ1Njc4OWxtbm9dEf --nopasscode --config-dir ${VITAL_SCRIPT_DIR} --config-file demo-witness-oobis-schema
kli incept --name subunit --alias subunit --file ${VITAL_SCRIPT_DIR}/data/vital-sample.json
SUBUNIT_AID=$(kli aid --name subunit --alias subunit)

echo 'resolving GLEIF External'
kli oobi resolve --name qvi --oobi-alias "GLEIF External" --oobi http://127.0.0.1:5642/oobi/EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name legal-entity --oobi-alias "GLEIF External" --oobi http://127.0.0.1:5642/oobi/EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name subunit --oobi-alias "GLEIF External" --oobi http://127.0.0.1:5642/oobi/EE9CDfykPbT--_v5i8HhSS8qj47YTOrumUkrvxLXSj2R/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
echo 'resolving qvi'
kli oobi resolve --name "GLEIF External" --oobi-alias qvi --oobi http://127.0.0.1:5642/oobi/"${QVI_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name legal-entity --oobi-alias qvi --oobi http://127.0.0.1:5642/oobi/"${QVI_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name subunit --oobi-alias qvi --oobi http://127.0.0.1:5642/oobi/"${QVI_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
echo 'resolving legal-entity'
kli oobi resolve --name "GLEIF External" --oobi-alias legal-entity --oobi http://127.0.0.1:5642/oobi/"${LEGAL_ENTITY_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name qvi --oobi-alias legal-entity --oobi http://127.0.0.1:5642/oobi/"${LEGAL_ENTITY_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name subunit --oobi-alias legal-entity --oobi http://127.0.0.1:5642/oobi/"${LEGAL_ENTITY_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
echo 'resolving subunit'
kli oobi resolve --name "GLEIF External" --oobi-alias subunit --oobi http://127.0.0.1:5642/oobi/"${SUBUNIT_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name qvi --oobi-alias subunit --oobi http://127.0.0.1:5642/oobi/"${SUBUNIT_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha
kli oobi resolve --name legal-entity --oobi-alias subunit --oobi http://127.0.0.1:5642/oobi/"${SUBUNIT_AID}"/witness/BBilc4-L3tFUnfM_wJr4S4OJanAv_VmF_dJNN6vkf2Ha

kli vc registry incept --name "GLEIF External" --alias "GLEIF External" --registry-name vLEI-external
kli vc registry incept --name qvi --alias qvi --registry-name vLEI-qvi
kli vc registry incept --name legal-entity --alias legal-entity --registry-name vLEI-legal-entity
kli vc registry incept --name subunit  --alias subunit --registry-name vLEI-subunit

echo -e "\nIssue QVI credential vLEI from GLEIF External to QVI"
kli vc create --name "GLEIF External" --alias "GLEIF External" --registry-name vLEI-external --schema ${QVI_SCHEMA_SAID} --recipient "${QVI_AID}" --data @${VITAL_SCRIPT_DIR}/data/qvi-data.json
QVI_SAID=$(kli vc list --name "GLEIF External" --alias "GLEIF External" --issued --said --schema ${QVI_SCHEMA_SAID})
kli ipex grant --name "GLEIF External" --alias "GLEIF External" --said "${QVI_SAID}" --recipient "${QVI_AID}"
GRANT=$(kli ipex list --name qvi --alias qvi --poll --said)
kli ipex admit --name qvi --alias qvi --said "${GRANT}"
kli vc export --name qvi --alias qvi --said "${QVI_SAID}" --full> /tmp/qvi.cesr
kli vc list --name qvi --alias qvi

echo -e "\nIssue LE credential from QVI to Legal Entity - have to create the edges first"
QVI_SAID=`kli vc list --name qvi --alias qvi --said --schema ${QVI_SCHEMA_SAID}`
echo \"$QVI_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/legal-entity-edges-filter.jq  > /tmp/legal-entity-edges.json
kli saidify --file /tmp/legal-entity-edges.json
kli vc create --name qvi --alias qvi --registry-name vLEI-qvi --schema "${LE_SCHEMA_SAID}" --recipient "${LEGAL_ENTITY_AID}" --data @${VITAL_SCRIPT_DIR}/data/legal-entity-data.json --edges @/tmp/legal-entity-edges.json --rules @${VITAL_SCRIPT_DIR}/data/rules.json
SAID=$(kli vc list --name qvi --alias qvi --issued --said --schema "${LE_SCHEMA_SAID}")
kli ipex grant --name qvi --alias qvi --said "${SAID}" --recipient "${LEGAL_ENTITY_AID}"
GRANT=$(kli ipex list --name legal-entity --alias legal-entity --poll --said)
kli ipex admit --name legal-entity --alias legal-entity --said "${GRANT}"
kli vc list --name legal-entity --alias legal-entity

echo -e "\nIssue LegalEntitySubunitvLEICredential from Legal Entity to Subunit"
kli vc import --name subunit --file /tmp/qvi.cesr --said "${QVI_SAID}"
LE_SAID=`kli vc list --name legal-entity --alias legal-entity --said --schema ${LE_SCHEMA_SAID}`
echo \"$LE_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/subunit-edges-filter.jq > /tmp/subunit-edges.json
kli saidify --file /tmp/subunit-edges.json
kli vc create --name legal-entity --alias legal-entity --registry-name vLEI-legal-entity \
  --schema ${LE_SUBUNIT_SCHEMA_SAID} \
  --recipient "${SUBUNIT_AID}" \
  --data @${VITAL_SCRIPT_DIR}/data/subunit-data.json \
  --edges @/tmp/subunit-edges.json \
  --rules @${VITAL_SCRIPT_DIR}/data/rules.json
SUBUNIT_SAID=$(kli vc list --name legal-entity --alias legal-entity --issued --said --schema ${LE_SUBUNIT_SCHEMA_SAID})
kli ipex grant --name legal-entity --alias legal-entity --said "${SUBUNIT_SAID}" --recipient "${SUBUNIT_AID}"
GRANT=$(kli ipex list --name subunit --alias subunit --poll --said)
kli ipex admit --name subunit --alias subunit --said "${GRANT}"
kli vc export --name subunit --alias subunit --said "${SUBUNIT_SAID}" --full> /tmp/subunit.cesr
kli vc list --name subunit --alias subunit

echo -e "\nIssue LESRAuthorizationvLEICredential from Legal Entity to QVI"
SUBUNIT_SAID=`kli vc list --name subunit --alias subunit --said --schema ${LE_SUBUNIT_SCHEMA_SAID}`
kli vc import --name qvi --file /tmp/subunit.cesr --said "${SUBUNIT_SAID}"
echo \"$SUBUNIT_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/lesr-auth-edges-filter.jq > /tmp/lesr-auth-edges.json
kli saidify --file /tmp/lesr-auth-edges.json
kli vc create --name legal-entity --alias legal-entity --registry-name vLEI-legal-entity \
  --schema ${LESR_AUTH_SCHEMA_SAID} \
  --recipient "${QVI_AID}" \
  --data @${VITAL_SCRIPT_DIR}/data/lesr-auth-data.json \
  --edges @/tmp/lesr-auth-edges.json \
  --rules @${VITAL_SCRIPT_DIR}/data/rules.json
LESR_AUTH_SAID=$(kli vc list --name legal-entity --alias legal-entity --issued --said --schema ${LESR_AUTH_SCHEMA_SAID})
kli ipex grant --name legal-entity --alias legal-entity --said "${LESR_AUTH_SAID}" --recipient "${QVI_AID}"
GRANT=$(kli ipex list --name qvi --alias qvi --poll --said | tail -1)
kli ipex admit --name qvi --alias qvi --said "${GRANT}"
kli vc export --name qvi --alias qvi --said "${LESR_AUTH_SAID}" --full> /tmp/lesr_auth.cesr
kli vc list --name qvi --alias qvi

echo -e "\nIssue LegalEntitySubunitRolevLEICredential from QVI to Subunit"
AUTH_SAID=`kli vc list --name qvi --alias qvi --said --schema ${LESR_AUTH_SCHEMA_SAID}`
echo \"$AUTH_SAID\" | jq -f ${VITAL_SCRIPT_DIR}/data/lesr-edges-filter.jq > /tmp/lesr-edges.json
kli vc import --name subunit --file /tmp/lesr_auth.cesr --said "${LESR_AUTH_SAID}"
kli saidify --file /tmp/lesr-edges.json
kli vc create --name qvi --alias qvi --registry-name vLEI-qvi \
  --schema ${LESR_SCHEMA_SAID} \
  --recipient "${SUBUNIT_AID}" \
  --data @${VITAL_SCRIPT_DIR}/data/lesr-data.json \
  --edges @/tmp/lesr-edges.json \
  --rules @${VITAL_SCRIPT_DIR}/data/rules.json
SAID=$(kli vc list --name qvi --alias qvi --issued --said --schema ${LESR_SCHEMA_SAID})
kli ipex grant --name qvi --alias qvi --said "${SAID}" --recipient "${SUBUNIT_AID}"
GRANT=$(kli ipex list --name subunit --alias subunit --poll --said | tail -1)
kli ipex admit --name subunit --alias subunit --said "${GRANT}"
kli vc list --name subunit --alias subunit

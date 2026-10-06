#!/bin/bash

vital schema generate --dir schema/ --oobi oobi/
s3cmd sync ./oobi/ s3://healthkeri-schema/oobi/ --acl-public --mime-type=application/json
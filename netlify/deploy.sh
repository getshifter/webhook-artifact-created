#!/bin/bash -x


env

if [ "${INCOMING_HOOK_BODY}" == "" ] ; then
  exit 0
fi

DOWNLOAD_URL=$(echo "${INCOMING_HOOK_BODY}" | jq -r .download_url | base64 -d)
ARTIFACT_ID=$(echo "${INCOMING_HOOK_BODY}" | jq -r .artifact_id)

wget -O "${ARTIFACT_ID}.tgz" "${DOWNLOAD_URL}"
tar xvzf "${ARTIFACT_ID}".tgz
mv "${ARTIFACT_ID}" public

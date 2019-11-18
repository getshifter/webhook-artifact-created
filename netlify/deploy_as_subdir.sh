#!/bin/bash -x


env

if [ "${INCOMING_HOOK_BODY}" == "" ] ; then
  exit 0
fi

DOWNLOAD_URL=$(echo "${INCOMING_HOOK_BODY}" | jq -r .download_url | base64 -d)
ARTIFACT_ID=$(echo "${INCOMING_HOOK_BODY}" | jq -r .artifact_id)

wget -O "${ARTIFACT_ID}.tgz" "${DOWNLOAD_URL}"
tar xvzf "${ARTIFACT_ID}".tgz

export SUBDIR=${SUBDIR:-blog}
export BASE_NAME=${BASE_NAME:-example.on.getshifter.io}
export NEW_NAME=${BASE_NAME:-example.com}

# Rewrite `/`` to `/blog/``
find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e 's@<a( [^\/>]*)href="/@<a$1href="/$ENV{SUBDIR}/@gsi' {} \;
find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e "s@<a( [^\/>]*)href='/@<a $1href='/\$ENV{SUBDIR}/@gsi" {} \;

find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e "s@'/wp-content@/\$ENV{SUBDIR}/wp-content@gsi" {} \;
find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e "s@'/wp-includes@'/\$ENV{SUBDIR}/wp-includes@gsi" {} \;

find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e 's@"/wp-content@"/$ENV{SUBDIR}/wp-content@gsi' {} \;
find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e 's@"/wp-includes@"/$ENV{SUBDIR}/wp-includes@gsi' {} \;

find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e 's@\s/wp-content@ /$ENV{SUBDIR}/wp-content@gsi' {} \;
find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e 's@\s/wp-includes@ /$ENV{SUBDIR}/wp-includes@gsi' {} \;

# update meta
find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e "s@<meta( [^\/>]*)content='https://\$ENV{BASE_NAME}/@<meta $1content='https://\$ENV{NEW_NAME}/\$ENV{SUBDIR}/@gsi" {} \;
find "${ARTIFACT_ID}" -name 'index.html' -exec perl -pi -e 's@<meta( [^\/>]*)content="https://$ENV{BASE_NAME}/@<meta $1content="https://$ENV{NEW_NAME}/$ENV{SUBDIR}/@gsi' {} \;

# update feed
perl -pi -e 's@<link>https://$ENV{BASE_NAME}@<link>https://$ENV{NEW_NAME}/$ENV{SUBDIR}@gsi' "${ARTIFACT_ID}"/feed/index.html
perl -pi -e 's@<atom:link( [^\/>]*)href="https://$ENV{BASE_NAME}@<atom:link$1href="https://$ENV{NEW_NAME}/$ENV{SUBDIR}@gsi' "${ARTIFACT_ID}"/feed/index.html

# finalize
mv "${ARTIFACT_ID}" public

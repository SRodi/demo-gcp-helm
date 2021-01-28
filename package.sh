#!/bin/sh



OWNER=${1}
REPOSITORY=${2}
BRANCH=${3}
TARGET_DIR=${4}
COMMIT_USERNAME=${5}
COMMIT_EMAIL=${6}

CHARTS_URL="https://${OWNER}.github.io/${REPOSITORY}"
REPO_URL="https://github.com/${OWNER}/${REPOSITORY}.git"


#############################################################
# package a chart directory into a chart archive
#############################################################


helm package helm

#############################################################
# move the archive to 
#############################################################


git clone ${REPO_URL}
cd ${REPOSITORY}
git config user.name "${COMMIT_USERNAME}"
git config user.email "${COMMIT_EMAIL}"
git remote set-url origin ${REPO_URL}
git checkout ${BRANCH}

mkdir -p ${TARGET_DIR}
mv -f ./*.tgz ${TARGET_DIR}

if [[ -f "${TARGET_DIR}/index.yaml" ]]; then
    echo "Found index, merging changes"
    helm repo index ${TARGET_DIR} --url ${CHARTS_URL} --merge "${TARGET_DIR}/index.yaml"
else
    echo "No index found, generating a new one"
    helm repo index ${TARGET_DIR} --url ${CHARTS_URL}
fi

git add ${TARGET_DIR}
git commit -m "Published Helm charts"
git push origin ${BRANCH}
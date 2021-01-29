#!/bin/sh



OWNER=${1}
REPOSITORY=${2}
BRANCH=${3}
TARGET_DIR=${4}
COMMIT_USERNAME=${5}
COMMIT_EMAIL=${6}

APP_VERSION=${7}
CHART_VERSION=${8}

GITHUB_TOKEN=${9}

CHARTS_TMP_DIR=$(mktemp -d)

CHARTS_URL="https://${OWNER}.github.io/${REPOSITORY}"
REPO_URL=""
HELM_CHART_DIR="helm-chart"

if [[ -z "$REPO_URL" ]]; then
    REPO_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/${OWNER}/${REPOSITORY}"
fi

if [[ -z "$COMMIT_USERNAME" ]]; then
    COMMIT_USERNAME="${GITHUB_ACTOR}"
fi

if [[ -z "$COMMIT_EMAIL" ]]; then
    COMMIT_EMAIL="${GITHUB_ACTOR}@users.noreply.github.com"
fi

if [[ -z "$TARGET_DIR" ]]; then
    TARGET_DIR="."
fi


#############################################################
# package a chart directory into a chart archive
#############################################################

helm init --client-only
helm package ${HELM_CHART_DIR} --destination ${CHARTS_TMP_DIR} $APP_VERSION_CMD$CHART_VERSION_CMD

#############################################################
# move the archive to 
#############################################################


git clone ${REPO_URL}
cd ${HELM_CHART_DIR}
git config user.name "${COMMIT_USERNAME}"
git config user.email "${COMMIT_EMAIL}"
git remote set-url origin ${REPO_URL}
git fetch
git checkout ${BRANCH}
cd ..

charts=$(cd ${CHARTS_TMP_DIR} && ls *.tgz | xargs)

mkdir -p ${TARGET_DIR}
mv -f ${CHARTS_TMP_DIR}/*.tgz ${TARGET_DIR}

if [[ -f "${TARGET_DIR}/index.yaml" ]]; then
    echo "Found index, merging changes"
    helm repo index ${TARGET_DIR} --url ${CHARTS_URL} --merge "${TARGET_DIR}/index.yaml"
else
    echo "No index found, generating a new one"
    helm repo index ${TARGET_DIR} --url ${CHARTS_URL}
fi

git add .
git commit -m "Published Helm charts"
git push origin ${BRANCH}
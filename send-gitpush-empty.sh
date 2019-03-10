#! /bin/bash

set -eux

TRAVIS_BLOG_TOKEN=${GITHUB_TOKEN:-''}

if [ -z $GITHUB_TOKEN ]
then
    echo "Token empty"
    exit 0
else
  DEPLOY_REPO="https://${GITHUB_TOKEN}@github.com/dagope/dagope.github.io.git"
fi

if [ -z "${TRAVIS_PULL_REQUEST:-''}" ]; then
    echo "except don't publish site for pull requests"
    exit 0
fi  

echo "Branc: ${TRAVIS_BRANCH:-''}"

if [ "${TRAVIS_BRANCH:-''}" != "development" ]; then
    echo "except we should only publish the development branch. stopping here"
    exit 0
fi

echo "deploying changes: ${TRAVIS_BUILD_NUMBER:-'unknown'}"

git clone --progress --depth 1 $DEPLOY_REPO _site

cd _site

git remote update
git pull
git status
git checkout test-travis

git config --global user.name "Travis CI"
git config --global user.email dagope+travis@gmail.com

git commit -m "rebuild pages: ${TRAVIS_BUILD_NUMBER:-'unknown'} " --allow-empty
git push $DEPLOY_REPO test-travis:test-travis
exit $?
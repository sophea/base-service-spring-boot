#!/usr/bin/env bash

basedir=$(dirname $0)

lastCommitAuthor=$(git log -1 | grep Author | awk '{print $2}')

if [[ "${lastCommitAuthor}" == "JBackend" ]]; then
    echo There are no changes since the last release, aborting release creation.
    exit 0;
fi

$basedir/version/closeVersion.sh
$basedir/docker-build-image.sh
$basedir/docker-push-image.sh


git add $basedir/../version
git commit -m "JENKINS: Closed release `$basedir/version/getVersion.sh`"
git push --set-upstream origin master

$basedir/version/increaseVersion.sh
git add $basedir/../version
git commit -m "JENKINS: Created new snapshot version `$basedir/version/getVersion.sh`"
git push --set-upstream origin master

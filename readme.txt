=========Release job========
./scripts/version/closeVersion.sh
./scripts/docker-build-image.sh
./scripts/docker-push-image.sh

tag=$(cat scripts/nexus.data)/virgin-base-service-spring-boot:`./scripts/version/getVersion.sh`
docker save --output $WORKSPACE/virgin-base-service-spring-boot-`./scripts/version/getVersion.sh`.tar ${tag}

git add version
git commit -m "JENKINS: Closed release `./scripts/version/getVersion.sh`"
git push --set-upstream origin master

./scripts/version/increaseVersion.sh
git add version
git commit -m "JENKINS: Created new snapshot version `./scripts/version/getVersion.sh`"
git push --set-upstream origin master

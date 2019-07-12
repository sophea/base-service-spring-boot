FROM openjdk:8u181-jdk-alpine
MAINTAINER Sophea Mak<sopheamak@gmail.com>
#RUN apk update && apk add bash curl jq gettext bc tini
RUN apk update && apk add bash tini
ADD ./container/ /
USER nobody
#HEALTHCHECK --interval=20s --timeout=3s --start-period=1800s CMD /app/check_running.sh

ENTRYPOINT ["/sbin/tini" , "--", "/app/start-spring-boot-app.sh"]

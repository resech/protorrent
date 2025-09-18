FROM alpine:latest
LABEL maintainer="ReSech"

ENV XDG_CONFIG_HOME="/config" \
  XDG_DATA_HOME="/config" \
  HOME="/config" \
  QBT_WEBUI_PORT=8080 \
  S6_VERBOSITY=1

ARG S6_OVERLAY_VERSION=3.2.1.0

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp
ADD https://github.com/VueTorrent/VueTorrent/releases/latest/download/vuetorrent.zip /tmp
COPY root /

RUN \
  echo "*** install s6 ***" && \
  tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
  tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
  tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz && \
  tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz && \
  echo "*** install VueTorrent ***" && \
  unzip /tmp/vuetorrent.zip -d / && \
  echo "*** perform updates ***" && \
  apk upgrade && \
  echo "*** install packages ***" && \
  apk add patch tzdata bash shadow wireguard-tools iptables libnatpmp libcap-utils qbittorrent-nox curl jq && \
  echo "*** patch wg-quick ***" && \
  patch --verbose -d / -p 0 -i /tmp/wg-quick.patch && \
  echo "**** create abc user and make our folders ****" && \
  groupmod -g 1000 -n abc users && \
  useradd -u 1000 -g 1000 -d /config -s /bin/false abc && \
  mkdir -p /config /downloads && \
  echo "*** cleanup ***" && \
  apk del patch && \
  rm -rf /var/cache/apk/* && \
  rm -rf /tmp/*

EXPOSE 8080
VOLUME /config
VOLUME /downloads
ENTRYPOINT [ "/init" ]

FROM alpine:edge AS downloader

ARG S6_OVERLAY_VERSION=3.2.1.0

RUN apk add --no-cache curl unzip && \
    cd /tmp && \
    curl -L -o s6-overlay-noarch.tar.xz \
      "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" && \
    curl -L -o s6-overlay-x86_64.tar.xz \
      "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz" && \
    curl -L -o s6-overlay-symlinks-noarch.tar.xz \
      "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz" && \
    curl -L -o s6-overlay-symlinks-arch.tar.xz \
      "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz" && \
    curl -L -o vuetorrent.zip \
      "https://github.com/VueTorrent/VueTorrent/releases/latest/download/vuetorrent.zip" && \
    curl -L -o qbittorrent-nox \
      "https://github.com/userdocs/qbittorrent-nox-static/releases/latest/download/x86_64-qbittorrent-nox" && \
    unzip -q vuetorrent.zip -d /vuetorrent && \
    chmod 755 qbittorrent-nox

FROM alpine:edge
LABEL maintainer="ReSech"

ENV XDG_CONFIG_HOME="/config" \
    XDG_DATA_HOME="/config" \
    HOME="/config" \
    QBT_WEBUI_PORT=8080 \
    S6_VERBOSITY=1

COPY --from=downloader /tmp/s6-overlay-*.tar.xz /tmp/
COPY --from=downloader /tmp/qbittorrent-nox /usr/bin/qbittorrent-nox
COPY --from=downloader /vuetorrent/vuetorrent /vuetorrent
COPY root /

RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-symlinks-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-symlinks-arch.tar.xz && \
    rm /tmp/s6-overlay-*.tar.xz && \
    apk add --no-cache \
      tzdata \
      bash \
      wireguard-tools \
      iptables \
      libnatpmp \
      libcap-utils \
      curl \
      patch \
      jq && \
    patch --verbose -d / -p 0 -i /tmp/wg-quick.patch && \
    apk del --no-cache patch && \
    addgroup -g 1000 abc && \
    adduser -D -u 1000 -G abc -h /config -s /bin/false abc && \
    mkdir -p /config /downloads && \
    rm -rf /tmp/* /var/cache/apk/*

EXPOSE 8080
VOLUME /config
VOLUME /downloads
ENTRYPOINT [ "/init" ]

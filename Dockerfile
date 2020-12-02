FROM --platform=${TARGETPLATFORM:-linux/amd64} debian:stable-slim

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ARG TARGETPLATFORM
ARG BUILDPLATFORM
RUN printf "I am running on ${BUILDPLATFORM:-linux/amd64}, building for ${TARGETPLATFORM:-linux/amd64}\n$(uname -a)\n"

LABEL maintainer="Redoracle" \
  org.opencontainers.image.created=$BUILD_DATE \
  org.opencontainers.image.url="https://github.com/redoracle/docker_fail2ban" \
  org.opencontainers.image.source="https://github.com/redoracle/docker_fail2ban" \
  org.opencontainers.image.version=$VERSION \
  org.opencontainers.image.revision=$VCS_REF \
  org.opencontainers.image.vendor="Redoracle" \
  org.opencontainers.image.title="Fail2ban" \
  org.opencontainers.image.description="Fail2ban" \
  org.opencontainers.image.licenses="MIT"

# Initialize Env
RUN apt update \
    && apt -y install curl \
    ipset \
    iptables \
    kmod \
    nftables \
    python3 \
    python-setuptools \
    msmtp \
    tzdata \
    wget \
    unzip \
    whois \
    bash python3 build-essential \
    python3-pip \
    python3-dev \
  && pip3 install --upgrade pip \
  && pip3 install dnspython3 pyinotify \
  && wget https://raw.githubusercontent.com/redoracle/docker_fail2ban/main/build.sh \
  && bash ./build.sh \
  && apt remove -y build-essential \
  && apt -y purge && apt -y clean && apt -y autoremove \
  && rm -rf /etc/fail2ban/jail.d /tmp/* rm /var/cache/* /var/lib/apt/lists/* 

ADD https://raw.githubusercontent.com/redoracle/docker_fail2ban/main/entrypoint.sh /

RUN chmod a+x /entrypoint.sh

VOLUME [ "/data" ]

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "fail2ban-server", "-f", "-x", "-v", "start" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD fail2ban-client ping || exit 1

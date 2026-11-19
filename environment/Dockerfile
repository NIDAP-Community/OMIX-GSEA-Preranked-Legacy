# hash:sha256:0cce2a33fd492df9b540c315c2782eafd4672b915a75bcc1e94e04afe05c38d2
ARG REGISTRY_HOST
FROM $REGISTRY_HOST/codeocean/omix-r-pathway:r4.4.3-bioconductor3.20-v3

ARG DEBIAN_FRONTEND=noninteractive
ARG GIT_ASKPASS
COPY git-ask-pass /

COPY postInstall /
RUN --mount=type=secret,id=secrets . /run/secrets/secrets \
    && /postInstall

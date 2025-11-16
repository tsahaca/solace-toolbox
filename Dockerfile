# ---- Stage 1: fetch stm binary (from GitHub or your own URL) ----
FROM alpine:3.20 AS downloader
RUN apk add --no-cache curl tar unzip
WORKDIR /tmp

# Replace this URL with the actual stm Linux binary tarball
RUN curl -L -o stm-alpine "https://github.com/SolaceLabs/solace-tryme-cli/releases/download/v0.0.83/stm-alpine-v0.0.83.zip" \
    && unzip stm-alpine.zip

# ---- Stage 2: final runtime image ----
FROM alpine:3.20

# Minimal deps; add others if stm needs them (e.g. node, openssl, etc.)
RUN apk add --no-cache ca-certificates \
    && update-ca-certificates

# Copy stm from the first stage
COPY --from=downloader /tmp/stm-alpine /usr/local/bin/stm

RUN chmod +x /usr/local/bin/stm

ENTRYPOINT ["stm"]
CMD ["--help"]

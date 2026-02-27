# ---- Stage 1: fetch stm binary (from GitHub or your own URL) ----
FROM alpine:3.20 AS downloader
# Use this for Alpine v3.18+
RUN apk update --no-check-certificate && apk add --no-cache --no-check-certificate curl tar unzip

# RUN apk add --no-cache curl tar unzip
WORKDIR /tmp

# Replace this URL with the actual stm Linux binary tarball
RUN curl -k -L -o stm-alpine.zip "https://github.com/SolaceLabs/solace-tryme-cli/releases/download/v0.0.83/stm-alpine-v0.0.83.zip" \
    && unzip stm-alpine.zip

# ---- Stage 2: final runtime image ----
FROM alpine:3.20

# Minimal deps; add others if stm needs them (e.g. node, openssl, etc.)
RUN apk add --no-cache ca-certificates \
    && update-ca-certificates

# Copy stm from the first stage
COPY --from=downloader /tmp/stm-alpine /usr/local/bin/stm

RUN chmod +x /usr/local/bin/stm

# Create a non-root user and group
RUN addgroup -S client && adduser -S client -G client

# Create a writable directory for the user (optional)
RUN mkdir -p /app && chown -R client:client /app

# If stm or other binaries need access to files, fix permissions
# Example:
RUN chown client:client /usr/local/bin/stm

# Switch to non-root user
USER client
WORKDIR /app

ENTRYPOINT ["stm"]
CMD ["--help"]

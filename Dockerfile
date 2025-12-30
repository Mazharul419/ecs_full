# Stage 1: Build stage

FROM node:22.21-bullseye AS builder
WORKDIR /usr/src/
RUN npm install -g npm@11.6.2
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential g++ python-is-python3 \
    libx11-dev libxkbfile-dev libsecret-1-dev libkrb5-dev \
    git git-lfs quilt \
    rsync jq gnupg \
    libgcc1 \
    && rm -rf /var/lib/apt/lists/*
RUN git clone --recursive --depth 1 https://github.com/coder/code-server.git code-server
WORKDIR /usr/src/code-server
RUN npm install
RUN npm run build
RUN VERSION=4.107.0 npm run build:vscode
RUN KEEP_MODULES=1 npm run release
RUN npm run release:standalone
RUN adduser nonroot && chown nonroot:nonroot ./

# Stage 2: Run Build stage

FROM gcr.io/distroless/base-debian12
WORKDIR /app
COPY --from=builder /usr/lib/x86_64-linux-gnu/libstdc++.so.6 /lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/libgcc_s.so.1 /lib/x86_64-linux-gnu/
COPY --from=builder /usr/src/code-server/release-standalone/ ./ 
USER nonroot
EXPOSE 8080

ENTRYPOINT ["/app/lib/node", "out/node/entry.js"]
CMD ["--bind-addr", "0.0.0.0:8080", "--auth", "none"]
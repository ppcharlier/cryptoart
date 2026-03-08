# Stage 1: Build
FROM swift:5.9-jammy as builder

WORKDIR /build
COPY . .
RUN swift build -c release --static-swift-stdlib

# Stage 2: Run
FROM ubuntu:jammy

RUN apt-get update && apt-get install -y libcurl4 libxml2 ca-certificates && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /build/.build/release/App /app/App

# Create persistent storage folder
RUN mkdir -p /data
ENV DATA_PATH=/data

EXPOSE 8080
ENTRYPOINT ["/app/App", "serve", "--hostname", "0.0.0.0", "--port", "8080"]

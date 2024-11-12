# Build Stage
FROM golang:1.20 AS builder

# Install necessary packages
RUN apt-get update && apt-get install -y \
    libpcap-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum files if they exist
COPY go.mod go.sum ./

# Download Go module dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go application
RUN CGO_ENABLED=1 GOOS=linux GOARCH=amd64 go build -o sendframe sendframe.go

# Final Stage
FROM ubuntu:22.04

# Install libpcap runtime library
RUN apt-get update && apt-get install -y \
    libpcap0.8 \
    && rm -rf /var/lib/apt/lists/*

# Copy the binary from the builder stage
COPY --from=builder /app/sendframe /usr/local/bin/sendframe

# Set the entrypoint to the built binary
ENTRYPOINT ["/usr/local/bin/sendframe"]


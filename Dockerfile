#FROM image-registry.openshift-image-registry.svc:5000/openshift/ubi9-micro:latest 
#FROM golang:1.22-alpine AS builder
FROM image-registry.openshift-image-registry.svc:5000/openshift/ubi9-micro:latest AS builder

#FROM registry.redhat.io/ubi9/go-toolset AS builder

# Set working directory
WORKDIR /app

# Copy module files first (important for caching)

COPY src/go.mod .

USER root
RUN chown -R :0 . && chmod -R g=u .
USER 1001

RUN go mod tidy

# Copy the rest of the source code
COPY src .

# Build the binary
RUN go build -o main

# ---- Run stage ----
FROM registry.access.redhat.com/ubi9-micro:latest 

WORKDIR /app

# Copy binary from builder
COPY --from=builder /app/main .

# Expose port (change if needed)
EXPOSE 3000

# Run the app
CMD ["./main"]
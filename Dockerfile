FROM golang:latest as builder

# Application working directory ( Created if it doesn't exist )
WORKDIR /build
# Copy all files ignoring those specified in dockerignore
COPY ./app /build/

# Installing custom packages from github
RUN go get -d
# Execute instructions on a new layer on top of current image. Run in shell.
RUN CGO_ENABLED=0 go build -a -installsuffix cgo --ldflags "-s -w" -o /build/app/main

FROM alpine:3.9.4

# metadata for better organization
LABEL app="otsumami"
LABEL environment="production"
# Set workdir on current image
WORKDIR /app
# Leverage a separate non-root user for the application
RUN adduser -S -D -H -h /app appuser
# Change to a non-root user
USER appuser
# Add artifact from builder stage
COPY --from=builder /build/app/main /app/
# Expose port to host
EXPOSE 8080
# Run software with any arguments
ENTRYPOINT ["./main"]
FROM golang:1.19@sha256:bace16d065b3733fabbe1d282286afbb0e1043e03c91c4cd8e0e6d319c46eb3e AS build

WORKDIR /workspace
ENV GO111MODULE=on

COPY *.go go.mod *.sum ./

# Download
RUN go mod download

# Bulild
COPY cmd ./cmd
COPY internal ./internal

RUN CGO_ENABLED=0 go build -o app -ldflags '-w -extldflags "-static"' ./cmd

#Test
RUN  CCGO_ENABLED=0 go test -v ./...

# Use distroless as minimal base image to package the manager binary
# Refer to https://github.com/GoogleContainerTools/distroless for more details
# debug tag adds a shell (not recommended for prod)
FROM gcr.io/distroless/static:nonroot@sha256:1fa522fe6cfe020d50341f1ca561c099487bd44f8eb98d25d1920b07e05e40be
WORKDIR /
COPY --from=build /workspace/app /app/app
USER nonroot:nonroot

ENTRYPOINT ["/app/app"]

ARG IMAGE_SOURCE
#https://github.com/k8s-at-home/template-container-image
LABEL org.opencontainers.image.source $IMAGE_SOURCE 

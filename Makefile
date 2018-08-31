kpkgs          = $(shell go list ./... | grep -v /vendor/)

PREFIX                  ?= $(shell pwd)
BIN_DIR                 ?= $(shell pwd)
DOCKER_IMAGE_NAME       ?= capturemedia/php-fpm-exporter
DOCKER_IMAGE_TAG        ?= $(subst /,-,$(shell git rev-parse --abbrev-ref HEAD))

all: format vet test build

style:
	@echo ">> checking code style"
	@! gofmt -d $(shell find . -path ./vendor -prune -o -name '*.go' -print) | grep '^'

test:
	@echo ">> running short tests"
	go test -short $(pkgs)

format:
	@echo ">> formatting code"
	go fmt $(pkgs)

vet:
	@echo ">> vetting code"
	go vet $(pkgs)

build:
	@echo ">> building code"
	go build -a -tags netgo

docker:
	@echo ">> Building build container"
	@docker build -t "$(DOCKER_IMAGE_NAME):builder" -f Dockerfile.build .
	@docker run --rm -it --name go-builder -v $(shell pwd):/go/src/script-exporter -e CGO_ENABLED=0 -e GOOS=linux $(DOCKER_IMAGE_NAME):builder
	@echo ">> building docker image"
	@docker build -t "$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)" .
	@docker tag "$(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_TAG)" "$(DOCKER_IMAGE_NAME):latest"

.PHONY: all style format test vet build docker



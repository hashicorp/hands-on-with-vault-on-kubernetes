BUILD_ID := $(shell git rev-parse --short HEAD 2>/dev/null || echo no-commit-id)
IMAGE_NAME := anubhavmishra/exampleapp

.DEFAULT_GOAL := help
help: ## List targets & descriptions
	@cat Makefile* | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

clean: ## Clean the project
	rm -rf ./build
	mkdir ./build

deps:
	go get github.com/GeertJohan/go.rice
	go get github.com/GeertJohan/go.rice/rice
	go get .

build-service: ## Build the main Go service
	mkdir -p ./build/linux/amd64
	rice embed-go
	GOOS=linux GOARCH=amd64 go build -v -o ./build/linux/amd64/exampleapp .
	docker build -t $(IMAGE_NAME):$(BUILD_ID) .
	docker tag $(IMAGE_NAME):$(BUILD_ID) $(IMAGE_NAME):latest

push: ## docker push the service images tagged 'latest' & 'BUILD_ID'
	docker push $(IMAGE_NAME):$(BUILD_ID)
	docker push $(IMAGE_NAME):latest

deps-test:
	go get -t

test: ## Run tests, coverage reports, and clean (coverage taints the compiled code)
	go test -v .

run: ## Build and run the project
	mkdir -p ./build
	go build -o ./build/exampleapp && PORT=8080 CONFIG_FILE=config.txt ./build/exampleapp
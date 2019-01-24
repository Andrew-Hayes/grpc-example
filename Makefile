GRPC_GATEWAY_DIR := $(shell go list -f '{{ .Dir }}' -m github.com/grpc-ecosystem/grpc-gateway 2> /dev/null)
GO_INSTALLED := $(shell command -v go)
PROTOC_INSTALLED := $(shell command -v protoc)
BINDATA_INSTALLED := $(shell command -v go-bindata 2> /dev/null)
PGGG_INSTALLED := $(shell command -v protoc-gen-grpc-gateway 2> /dev/null)
PGS_INSTALLED := $(shell command -v protoc-gen-swagger 2> /dev/null)
PGG_INSTALLED := $(shell command -v protoc-gen-go 2> /dev/null)

all: generate

install-tools:
ifndef PROTOC_INSTALLED
	$(error "go is not installed, please run 'brew install go'")
endif
ifndef PROTOC_INSTALLED
	$(error "protoc is not installed, please run 'brew install protobuf'")
endif
ifndef BINDATA_INSTALLED
	@go get -u github.com/jteeuwen/go-bindata/go-bindata@master
endif
ifndef PGGG_INSTALLED
	@go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-grpc-gateway
endif
ifndef PGS_INSTALLED
	@go get -u github.com/grpc-ecosystem/grpc-gateway/protoc-gen-swagger
endif
ifndef PGG_INSTALLED
	@go get -u github.com/golang/protobuf/protoc-gen-go
endif

generate: install-tools
	@rm -rf factory
	@mkdir -p factory
	@protoc \
		-I/usr/local/include \
		-I. \
		-I$(GRPC_GATEWAY_DIR)/third_party/googleapis \
		--go_out=plugins=grpc:factory \
		--swagger_out=logtostderr=true:factory \
		--grpc-gateway_out=logtostderr=true:factory \
		--proto_path proto factory.proto
	@go generate ./...

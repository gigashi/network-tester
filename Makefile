NT_SERVER := ntserver
NT_CLIENT := ntclient

REVISION := $(shell git rev-parse --short HEAD)
SRCS     := $(shell find . -type f -name '*.go')
LDFLAGS  := -ldflags="-s -w -X \"main.Revision=$(REVISION)\" -extldflags \"-static\""

LINUX   := linux-amd64
MAC     := darwin-amd64
WINDOWS := windows-amd64

SERVER_TARGETS = ./bin/$(LINUX)/$(NT_SERVER) ./bin/$(MAC)/$(NT_SERVER) ./bin/$(WINDOWS)/$(NT_SERVER).exe
CLIENT_TARGETS = ./bin/$(LINUX)/$(NT_CLIENT) ./bin/$(MAC)/$(NT_CLIENT) ./bin/$(WINDOWS)/$(NT_CLIENT).exe
ZIP            = ./bin/network-tester.zip

# task

.PHONY: all
all: $(SERVER_TARGETS) $(CLIENT_TARGETS)

.PHONY: clean
clean:
	@rm -f $(SERVER_TARGETS) $(CLIENT_TARGETS) $(ZIP)

.PHONY: test
test:
	go vet ./...
	go mod tidy
	go test ./...

.PHONY: zip
zip: $(ZIP)
$(ZIP): $(SERVER_TARGETS) $(CLIENT_TARGETS)
	@zip -r $(ZIP) `find bin -type f | grep -v .gitignore`
	@unzip -Z $(ZIP)

# server

bin/$(LINUX)/$(NT_SERVER): $(SRCS)
	@ mkdir -p ./bin/$(LINUX)
	GOOS=linux   GOARCH=amd64 go build -a -tags netgo -installsuffix netgo $(LDFLAGS) -o bin/$(LINUX)/$(NT_SERVER) ./cmd/$(NT_SERVER)/main.go

bin/$(MAC)/$(NT_SERVER): $(SRCS)
	@ mkdir -p ./bin/$(MAC)
	GOOS=darwin  GOARCH=amd64 go build -a -tags netgo -installsuffix netgo $(LDFLAGS) -o bin/$(MAC)/$(NT_SERVER) ./cmd/$(NT_SERVER)/main.go

bin/$(WINDOWS)/$(NT_SERVER).exe: $(SRCS)
	@ mkdir -p ./bin/$(WINDOWS)
	GOOS=windows GOARCH=amd64 go build -a -tags netgo -installsuffix netgo $(LDFLAGS) -o bin/$(WINDOWS)/$(NT_SERVER).exe ./cmd/$(NT_SERVER)/main.go

# client

bin/$(LINUX)/$(NT_CLIENT): $(SRCS)
	@ mkdir -p ./bin/$(LINUX)
	GOOS=linux   GOARCH=amd64 go build -a -tags netgo -installsuffix netgo $(LDFLAGS) -o bin/$(LINUX)/$(NT_CLIENT) ./cmd/$(NT_CLIENT)/main.go

bin/$(MAC)/$(NT_CLIENT): $(SRCS)
	@ mkdir -p ./bin/$(MAC)
	GOOS=darwin  GOARCH=amd64 go build -a -tags netgo -installsuffix netgo $(LDFLAGS) -o bin/$(MAC)/$(NT_CLIENT) ./cmd/$(NT_CLIENT)/main.go

bin/$(WINDOWS)/$(NT_CLIENT).exe: $(SRCS)
	@ mkdir -p ./bin/$(WINDOWS)
	GOOS=windows GOARCH=amd64 go build -a -tags netgo -installsuffix netgo $(LDFLAGS) -o bin/$(WINDOWS)/$(NT_CLIENT).exe ./cmd/$(NT_CLIENT)/main.go

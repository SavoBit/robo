VERSION := $(shell git describe --tags --always --dirty="-dev")
LDFLAGS := -ldflags='-X "main.version=$(VERSION)"'

test:
	@go test -cover ./...

install-deps:
	dep ensure -v

verify-deps:
	test `dep ensure -no-vendor -dry-run | wc -l` -eq 0

lint: verify-deps
	go vet ./...

clean:
	rm -rf ./dist

build: clean
	mkdir dist
	GOOS=darwin GOARCH=amd64 go build $(LDFLAGS) -o dist/robo-$(VERSION)-darwin-amd64
	GOOS=linux GOARCH=amd64 go build $(LDFLAGS) -o dist/robo-$(VERSION)-linux-amd64

gh-release:
	go get -u github.com/aktau/github-release

release: gh-release
	github-release release \
	--security-token $$GH_LOGIN \
	--user segmentio \
	--repo robo \
	--tag $(VERSION) \
	--name $(VERSION)

	github-release upload \
	--security-token $$GH_LOGIN \
	--user segmentio \
	--repo robo \
	--tag $(VERSION) \
	--name robo-$(VERSION)-darwin-amd64 \
	--file dist/robo-$(VERSION)-darwin-amd64

	github-release upload \
	--security-token $$GH_LOGIN \
	--user segmentio \
	--repo robo \
	--tag $(VERSION) \
	--name robo-$(VERSION)-linux-amd64 \
	--file dist/robo-$(VERSION)-linux-amd64

.PHONY: test

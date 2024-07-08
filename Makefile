
# Build Vars
IMAGENAME ?= zhangguanzhang/netshoot
VERSION ?= $(shell git describe --tags --abbrev=0)

.DEFAULT_GOAL := all

clean:
	rm -rf build/bin/

# build/bin/amd64 build/bin/arm64
build/bin/%:
	mkdir -p $@
	ARCH=$* bash $(CURDIR)/build/fetch_binaries.sh

# build-amd64  build-arm64
build-%:
	$(MAKE) build/bin/$*
	@docker build --pull --platform linux/$* \
		-t ${IMAGENAME}:${VERSION} \
		-t ${IMAGENAME} \
		 .

build-all:
	@docker buildx build --pull --platform linux/amd64,linux/arm64 \
		--progress plain \
		-t $(IMAGENAME) \
		-t ${IMAGENAME}:${VERSION} \
		--push \
		--file ./Dockerfile .
 
all: build/bin/amd64 build/bin/arm64 build-all 

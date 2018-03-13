#!/usr/bin/make -f

CACHE_DIR:=$(HOME)/.cache/cargo
DOCKER_IMAGE:=naftulikay/circleci-amazonlinux-rust:lambda

build:
	@docker run -it --rm \
	  -v /vagrant:/home/circleci/project \
	  -v $(CACHE_DIR)/cargo/registry:/home/circleci/.cargo/registry \
	  -v $(CACHE_DIR)/target:/home/circleci/project/target \
	  -v $(PWD)/bin:/home/circleci/.local/bin \
	  $(DOCKER_IMAGE) \
	  .local/bin/build

clean:
	@docker run -it --rm \
		-v /vagrant:/home/circleci/project \
		-v $(CACHE_DIR)/cargo/registry:/home/circleci/.cargo/registry \
		-v $(CACHE_DIR)/target:/home/circleci/project/target \
		-v $(PWD)/bin:/home/circleci/.local/bin \
		$(DOCKER_IMAGE) \
		.local/bin/clean

test: build
	@docker run -it --rm \
		-v /vagrant:/home/circleci/project \
		-v $(CACHE_DIR)/cargo/registry:/home/circleci/.cargo/registry \
		-v $(CACHE_DIR)/target:/home/circleci/project/target \
		-v $(PWD)/bin:/home/circleci/.local/bin \
		$(DOCKER_IMAGE) \
		.local/bin/test

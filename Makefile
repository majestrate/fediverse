REPO := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

RM = rm -rf

BUILD_DIR=$(REPO)/build
REPO_GOPATH=$(BUILD_DIR)/go

PREFIX ?= /usr/local

ASSETS_DIR=$(REPO)/assets

STATIC=$(ASSETS_DIR)/static

GOROOT ?= $(shell go env GOROOT)
GO = $(GOROOT)/bin/go
# desired go version 
GO_VERSION ?= go1.10

GIT ?= $(shell which git)

YARN ?= $(shell which yarn)

BLOAT = $(REPO)/node_modules

TSC = $(BLOAT)/.bin/tsc
TSC_SRC = $(REPO)/frontend/ts
TSC_MAIN = $(TSC_SRC)/main.ts

APPJS = $(STATIC)/app.min.js

RICKD = $(BUILD_DIR)/clicker-rick

CONFIG_ROOT ?= $(REPO)/etc

CONFIG = $(CONFIG_ROOT)/clicker-rick.ini

_NOT_SET = not-set

EMAIL ?= $(_NOT_SET)

DOMAIN ?= $(_NOT_SET)

SERVER = github.com/majestrate/clicker-rick

GENCONF_SRC = $(SERVER)/cmd/fediverse-genconf

GENCONF = $(REPO_GOPATH)/bin/fediverse-genconf

all: help

help:
	@echo "usage: make [target]"
	@echo ""
	@echo "current (useful) targets:"
	@echo ""
	@echo "build     :build server source"
	@echo "bloat     :rebuild frontend js"
	@echo "configure :generate initial configs"
	@echo "refresh   :refresh server source and rebuild server"
	@echo "sandwich  :the equiv of make build configure run"
	@echo ""
	@echo "make sure to review readme.md"
	@echo ""


$(BLOAT):
	$(YARN) install

debloat:
	$(RM) $(BLOAT)
	$(RM) $(APPJS)

bloat: $(BLOAT) $(APPJS)

$(APPJS):
	$(TSC) $(TSC_MAIN) --outfile $(APPJS)

$(CONFIG_ROOT):
	mkdir $(CONFIG_ROOT)

$(GENCONF): 
	GOPATH=$(REPO_GOPATH) $(GO) get -u -v $(GENCONF_SRC)

$(CONFIG): $(CONFIG_ROOT) $(GENCONF)
	$(GENCONF) "$(EMAIL)" "$(DOMAIN)" "$(ASSETS_DIR)" "$(CONFIG)"

update:
	GOPATH=$(REPO_GOPATH) $(GO) get -u -d -v $(SERVER)

refresh:
	$(RM) $(RICKD)
	$(MAKE) -C $(REPO_GOPATH)/src/$(SERVER) update
	GOPATH=$(REPO_GOPATH) $(GO) build -a -o $(RICKD) $(SERVER)

build: update $(RICKD) bloat

$(RICKD):
	GOPATH=$(REPO_GOPATH) $(GO) build -a -o $(RICKD) $(SERVER)

ensure: ensure-params ensure-go ensure-git

ensure-params: check-email-set check-domain-set

check-email-set:
	test "email=$(EMAIL)" != "email=$(_NOT_SET)"

check-domain-set:
	test "domain=$(DOMAIN)" != "domain=$(_NOT_SET)"

ensure-git:
	test -x $(GIT)
	test $(shell $(GIT) --version | cut -d' ' -f3 | cut -d'.' -f 1) = 2

ensure-go:
	test -x $(GO)
	test $(shell $(GO) version | cut -d' ' -f3) = $(GO_VERSION)


sandwich: ensure build configure
	@echo "your sandwich is ready"
	@echo "                          ____"
	@echo "              .----------'    '-."
	@echo "             /  .      '     .   \\"
	@echo "            /        ' woah      /|"
	@echo "           /     nice            \\"
	@echo "          /  ' .       .     .  | \\"
	@echo "         /.___________    '    / /"
	@echo "         |._          '------'| / \\"
	@echo "         '.............______.-' /"
	@echo "         |-.                  | /"
	@echo "         \`------------.....---+'"
	@echo ""
	GIN_MODE=release $(RICKD) "$(CONFIG)"

reconfigure: ensure unconfigure configure

unconfigure:
	$(RM) $(CONFIG)

configure: ensure $(CONFIG)

run:
	GIN_MODE=release $(RICKD) "$(CONFIG)"

clean: debloat
	$(RM) $(RICKD)

distclean:
	$(RM) $(BUILD_DIR)
	$(GIT) clean -xdf

install:
	install $(RICKD) $(PREFIX)/bin
	install $(CONFIG) $(PREFIX)/etc


REPO := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

RM = rm -rf

BUILD_DIR=$(REPO)/build
REPO_GOPATH=$(BUILD_DIR)/go

GOROOT ?= $(shell go env GOROOT)
GO = $(GOROOT)/bin/go
# desired go version 
GO_VERSION ?= go1.10

GIT ?= $(shell which git)

RICKD = $(REPO_GOPATH)/bin/clicker-rick

CONFIG_ROOT ?= $(REPO)/etc

CONFIG = $(CONFIG_ROOT)/server.ini

_NOT_SET = not-set

EMAIL ?= $(_NOT_SET)

DOMAIN ?= $(_NOT_SET)

SERVER = github.com/majestrate/clicker-rick

GENCONF_SRC = $(SERVER)/cmd/fediverse-genconf

GENCONF = $(REPO_GOPATH)/bin/fediverse-genconf

all: clean build

$(CONFIG_ROOT):
	mkdir $(CONFIG_ROOT)

$(GENCONF):
	GOPATH=$(REPO_GOPATH) $(GO) get -u -v $(GENCONF_SRC)

$(CONFIG): ensure-params $(CONFIG_ROOT) $(GENCONF)
	$(GENCONF) "$(EMAIL)" "$(DOMAIN)" "$(CONFIG)"

update:
	GOPATH=$(REPO_GOPATH) $(GO) get -u -d -v $(SERVER)

build: $(RICKD)

$(RICKD): update
	GOPATH=$(REPO_GOPATH) $(GO) install $(SERVER)

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

configure: ensure $(CONFIG)

run: $(RICKD) $(CONFIG)
	$(RICKD) "$(CONFIG)"

clean:
	$(RM) $(BUILD_DIR)

distclean:
	$(GIT) clean -xdf



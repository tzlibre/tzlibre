PACKAGES:=$(patsubst %.opam,%,$(notdir $(shell find src vendors -name \*.opam -print)))

active_protocol_versions := $(shell cat active_protocol_versions)
active_protocol_directories := $(shell tr -- - _ < active_protocol_versions)

current_opam_version := $(shell opam --version)
include scripts/version.sh

ifeq ($(filter ${opam_version}.%,${current_opam_version}),)
$(error Unexpected opam version (found: ${current_opam_version}, expected: ${opam_version}.*))
endif

current_ocaml_version := $(shell opam exec -- ocamlc -version)

all: generate_dune
ifneq (${current_ocaml_version},${ocaml_version})
	$(error Unexpected ocaml version (found: ${current_ocaml_version}, expected: ${ocaml_version}))
endif
	@dune build \
		src/bin_node/main.exe \
		src/bin_client/main_client.exe \
		src/bin_client/main_admin.exe \
		src/bin_signer/main_signer.exe \
		src/lib_protocol_compiler/main_native.exe \
		$(foreach p, $(active_protocol_directories), src/proto_$(p)/bin_baker/main_baker_$(p).exe) \
		$(foreach p, $(active_protocol_directories), src/proto_$(p)/bin_endorser/main_endorser_$(p).exe) \
		$(foreach p, $(active_protocol_directories), src/proto_$(p)/bin_accuser/main_accuser_$(p).exe)
	@cp _build/default/src/bin_node/main.exe tzlibre-node
	@cp _build/default/src/bin_client/main_client.exe tzlibre-client
	@cp _build/default/src/bin_client/main_admin.exe tzlibre-admin-client
	@cp _build/default/src/bin_signer/main_signer.exe tzlibre-signer
	@cp _build/default/src/lib_protocol_compiler/main_native.exe tzlibre-protocol-compiler
	@for p in $(active_protocol_directories) ; do \
	   cp _build/default/src/proto_$$p/bin_baker/main_baker_$$p.exe tzlibre-baker-`echo $$p | tr -- _ -` ; \
	   cp _build/default/src/proto_$$p/bin_endorser/main_endorser_$$p.exe tzlibre-endorser-`echo $$p | tr -- _ -` ; \
	   cp _build/default/src/proto_$$p/bin_accuser/main_accuser_$$p.exe tzlibre-accuser-`echo $$p | tr -- _ -` ; \
	 done

PROTOCOLS := 000_Ps8LKGP9 001_Havana demo
DUNE_INCS=$(patsubst %,src/proto_%/lib_protocol/dune.inc, ${PROTOCOLS})

generate_dune: ${DUNE_INCS}

${DUNE_INCS}:: src/proto_%/lib_protocol/dune.inc: \
  src/proto_%/lib_protocol/TEZOS_PROTOCOL
	dune build @$(dir $@)/runtest_dune_template --auto-promote
	touch $@

all.pkg: generate_dune
	@dune build \
	    $(patsubst %.opam,%.install, $(shell find src vendors -name \*.opam -print))

$(addsuffix .pkg,${PACKAGES}): %.pkg:
	@dune build \
	    $(patsubst %.opam,%.install, $(shell find src vendors -name $*.opam -print))

$(addsuffix .test,${PACKAGES}): %.test:
	@dune build \
	    @$(patsubst %/$*.opam,%,$(shell find src vendors -name $*.opam))/runtest

build-sandbox:
	@dune build src/bin_flextesa/main.exe
	@cp _build/default/src/bin_flextesa/main.exe tzlibre-sandbox

build-test: build-sandbox
	@dune build @buildtest

test:
	@dune runtest
	@./scripts/check_opam_test.sh

test-indent:
	@dune build @runtest_indent

fix-indent:
	@src/lib_stdlib/test-ocp-indent.sh fix

build-deps:
	@./scripts/install_build_deps.sh

build-dev-deps:
	@./scripts/install_build_deps.sh --dev

install:
	@dune build @install
	@dune install

uninstall:
	@dune uninstall

clean:
	@-dune clean
	@-find . -name dune-project -delete
	@-rm -f \
		tzlibre-node \
		tzlibre-client \
		tzlibre-signer \
		tzlibre-admin-client \
		tzlibre-protocol-compiler \
	  $(foreach p, $(active_protocol_versions), tzlibre-baker-$(p) tzlibre-endorser-$(p) tzlibre-accuser-$(p))
	@-rm -f docs/api/tzlibre-{baker,endorser,accuser}-alpha.html docs/api/tzlibre-{admin-,}client.html docs/api/tzlibre-signer.html

.PHONY: all test build-deps docker-image clean


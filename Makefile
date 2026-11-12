.PHONY: install update doctor audit test

install:
	./install.sh --brew $(if $(HOST),--host $(HOST))

update:
	./bin/dot update

doctor:
	./bin/dot doctor

audit:
	./bin/dot audit

test:
	./scripts/test.sh

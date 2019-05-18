TARGETS := $(shell ls scripts | grep -v \\.sh)

.SILENT:

up:
	-docker-compose rm -f -s
	docker-compose up -d

setup: config.yaml hosts

cleanup:
	-docker-compose rm -f -s
	-docker volume rm k3s_k3s-server
	-rm config.yaml
	$(MAKE) clean-hosts

config.yaml: hosts
	docker-compose exec server cat /output/kubeconfig.yaml > $@
	sed -i -e 's/localhost/k3s/' $@

hosts:
	grep "$$(ip route | grep default | awk '{print $$3}') k3s" /etc/hosts || \
	sudo bash -c "echo $$(ip route | grep default | awk '{print $$3}') k3s >> /etc/hosts"

clean-hosts:
	cp /etc/hosts hosts.new
	sed -i -e '/k3s/d' hosts.new
	sudo cp -f hosts.new /etc/hosts
	rm hosts.new

.dapper:
	@echo Downloading dapper
	@curl -sL https://releases.rancher.com/dapper/v0.4.2/dapper-`uname -s`-`uname -m` > .dapper.tmp
	@@chmod +x .dapper.tmp
	@./.dapper.tmp -v
	@mv .dapper.tmp .dapper

$(TARGETS): .dapper
	./.dapper $@

trash: .dapper
	./.dapper -m bind trash

trash-keep: .dapper
	./.dapper -m bind trash -k

deps: trash

release:
	./scripts/release.sh

.DEFAULT_GOAL := ci

.PHONY: $(TARGETS)

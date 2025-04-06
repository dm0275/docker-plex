PLEX_IMAGE="plexinc/pms-docker:latest"
PLEX_CLAIM=`cat plex.claim`
IP_ADDRESS="`ifconfig en1 | grep 'inet ' | awk '{print $$2}'`"

.PHONY: help
.PHONY: clean check_clean
.DEFAULT_GOAL := help

ENV=export TZ=America/Chicago \
	PLEX_PORT=32400 \
	PLEX_CLAIM=$(PLEX_CLAIM) \
	ADVERTISE_IP=http://$(IP_ADDRESS):32400/

run: setup ## Run Plex
	$(ENV) && docker compose up -d

run_i: setup ## Run Plex interactively
	$(ENV) && docker compose up

build:
	git clone https://github.com/plexinc/pms-docker.git
	cd pms-docker && docker build --platform linux/arm/v7 -t plexinc/pms-docker:latest .

login: ## Login to container
	$(ENV) && docker exec -it --user=plex plex bash

setup: ## Create DIRs
	mkdir -p config media transcode

stop: ## Stop Plex Container
	$(ENV) && docker compose stop

remove: ## Remove Plex container
	$(ENV) && docker compose rm -f -s

check_clean:
	@echo "Are you sure? [y/N] " && read ans && [ $${ans:-N} = y ]

clean-dirs: check_clean ## Clean DIRs
	@echo "rm -rf config media transcode"

help: ## This help dialog.
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


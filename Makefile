-include .env
APP_UID ?= 1000
APP_GID ?= 1000

IMAGE_NAME := laravel-setup-php-fpm
IMAGE_TAG  := latest
IMAGE      := $(IMAGE_NAME):$(IMAGE_TAG)
TAR_FILE   := $(IMAGE_NAME)_$(IMAGE_TAG).tar.gz

.PHONY: help build load shell docs db

help:
	@echo "Usage:"
	@echo "  make <target> [SOURCE=...]"
	@echo ""
	@echo "Targets:"
	@echo "  build         Build Docker image and save to archive"
	@echo "  load          Load Docker image from archive, URL, or build if missing"
	@echo "                Optional: SOURCE=url_or_file"
	@echo "  shell         Enter php-fpm container as www"
	@echo "  docs          Regenerate API documentation"
	@echo "  db            Recreate DB"


build:
	@echo "Building image..."
	docker build -f docker/Dockerfile --build-arg UID=$(APP_UID) --build-arg GID=$(APP_GID) -t $(IMAGE) .
	@echo "Saving image to $(TAR_FILE)..."
	docker save $(IMAGE) | gzip > $(TAR_FILE)

load:
ifdef SOURCE
	@if echo "$(SOURCE)" | grep -qE '^https?://'; then \
		echo "Downloading and loading image from $(SOURCE)..."; \
		curl -L "$(SOURCE)" -o $(TAR_FILE); \
		docker load < $(TAR_FILE); \
	else \
		echo "Loading image from file $(SOURCE)..."; \
		docker load < $(SOURCE); \
	fi
else
	@if [ -f "$(TAR_FILE)" ]; then \
		echo "Loading image from archive $(TAR_FILE)..."; \
		docker load < $(TAR_FILE); \
	else \
		echo "No archive found; building image..."; \
        docker build -f docker/Dockerfile --build-arg UID=$(APP_UID) --build-arg GID=$(APP_GID) -t $(IMAGE) .; \
	fi
endif

shell:
	@echo "Entering php-fpm container as www..."
	docker compose exec --user www php-fpm bash

docs:
	@echo "Regenerating API documentation..."
	docker compose exec --user www php-fpm php artisan scribe:generate

db:
	@echo "Recreate DB..."
	docker compose exec --user www php-fpm bash -c "php artisan migrate:fresh && php artisan db:seed"

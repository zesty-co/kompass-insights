# Makefile for Helm Chart Operations

# Variables
SHELL := /bin/bash

all: lint ensure-template-var-prefix template ## Run all operations that validate the correctness of the chart

.PHONY: lint
lint: ## Lint Helm chart
	@echo "Linting Helm chart..."
	@helm lint ./charts/* || exit 1;

.PHONY: template
template: ## Template Helm chart and validate output
	@echo "Templating Helm chart..."
	@helm template test-release ./charts/* --debug > /dev/null || exit 1;

TEMPLATE_PREFIX := zesty-k8s
.PHONY: ensure-template-var-prefix
ensure-template-var-prefix: ## Ensure all template variables start with "$(TEMPLATE_PREFIX)."
	@problem_keys=$$(find . -type f -name '*.tpl' \
		| xargs grep -Eo '{{-?[[:space:]]*define[[:space:]]*"[^"]+"' \
		| sed -E 's/.*define[[:space:]]*"([^"]+)".*/\1/' \
		| grep -v '^$(TEMPLATE_PREFIX)\.'); \
	if [ -n "$$problem_keys" ]; then \
		echo "Some template variables do not start with '$(TEMPLATE_PREFIX).' prefix."; \
		echo "$$problem_keys"; \
		exit 1; \
	fi
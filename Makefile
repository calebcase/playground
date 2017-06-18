SHELL := /bin/bash

UUID ?= $(shell cat uuid || uuidgen | tee uuid)
ENV ?= training

AWS_REGION ?= us-east-1
SSH_KEY ?= $(shell ssh-add -L | head -n 1)
SSH_KEY_PAIR ?= $(USER)

export

terragrunt_flags := --terragrunt-non-interactive --terragrunt-source-update

.PHONY: all
all: plan

.PHONY: plan
plan:
	@cd "$(ENV)" && terragrunt plan $(terragrunt_flags)

.PHONY: apply
apply:
	@cd "$(ENV)" && terragrunt apply $(terragrunt_flags)

.PHONY: destroy
destroy:
	@cd "$(ENV)" && terragrunt destroy $(terragrunt_flags)

.PHONY: import
import:
	@cd "$(ENV)" && terragrunt import $(terragrunt_flags) $(IMPORT_NAME) $(IMPORT_ID)

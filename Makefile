SHELL := /bin/bash

AWS_REGION ?= us-east-1

UUID ?= $(shell cat uuid || uuidgen | tee uuid)
ENV ?= training

export

terragrunt_flags := --terragrunt-non-interactive --terragrunt-source-update

.PHONY: all
all: plan

.PHONY: plan
plan: uuid
	@cd "$(ENV)" && terragrunt plan $(terragrunt_flags)

.PHONY: apply
apply: uuid
	@cd "$(ENV)" && terragrunt apply $(terragrunt_flags)

.PHONY: destroy
destroy: uuid
	@cd "$(ENV)" && terragrunt destroy $(terragrunt_flags)

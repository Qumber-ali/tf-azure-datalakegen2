SHELL := /bin/bash
ENVIRONMENT := $(shell echo $(env)) 
SUBSCRIPTION_ID = $(shell cat terraform.tfvars.json | jq '.tfstate_settings["subscription_id"]')
RESOURCE_GROUP_NAME = $(shell cat terraform.tfvars.json | jq '.tfstate_settings["resource_group_name"]')
STORAGE_ACCOUNT_NAME = $(shell cat terraform.tfvars.json | jq '.tfstate_settings["storage_account_name"]')
CONTAINER_NAME = $(shell cat terraform.tfvars.json | jq '.tfstate_settings["container_name"]')
TARGET_ARGUMENTS := $(shell echo $(target_arguments))

ifeq ($(strip $(ENVIRONMENT)),)
ifneq ($(MAKECMDGOALS), $(filter $(MAKECMDGOALS),fmt clean lint))
$(error "Please set the env environment variable before running make.")
endif
endif

.PHONY: init
init: 
	@rm -rf .terraform*
	@terraform init -backend-config="key=ootf-$(ENVIRONMENT)-terraform.state" -backend-config="resource_group_name=$(RESOURCE_GROUP_NAME)"\
         -backend-config="storage_account_name=$(STORAGE_ACCOUNT_NAME)" -backend-config="container_name=$(CONTAINER_NAME)"\
                          -backend-config="subscription_id=$(SUBSCRIPTION_ID)" 
	@terraform workspace select $(ENVIRONMENT) || terraform workspace new $(ENVIRONMENT) 

.PHONY: lint
lint: 
	@terraform validate
	@tflint --init
	@TF_LOG=debug tflint  

.PHONY: plan
plan: init lint
	@terraform plan $(TARGET_ARGUMENTS)

.PHONY: apply
apply: init lint
	@terraform apply $(TARGET_ARGUMENTS)

.PHONY: destroy
destroy: init
	@terraform destroy $(TARGET_ARGUMENTS)

.PHONY: fmt
fmt: 
	@terraform fmt -recursive

.PHONY: clean
clean:
	@rm -rf .terraform*

# Makefile

# Default to backend/.env, can be overridden
ENV_FILE := backend/.env
MIGRATIONS_PATH := backend/migrations

# Check if .env file exists
check_env:
ifeq (,$(wildcard $(ENV_FILE)))
	$(error $(ENV_FILE) not found. Please create it.)
endif

# Target to load .env and export variables, then run the command
# This exports variables for the subshell that runs the command.
run_with_env = @$(eval export $(shell sed 's/=.*//' $(ENV_FILE) | grep -v '^#' | grep -v '^$$')) \
	             $(eval export $(shell cat $(ENV_FILE) | grep -v '^#' | grep -v '^$$')) \
	             $(1)


# Migration tasks
# Note: golang-migrate CLI automatically reads DATABASE_URL from the environment.
migrate-up: check_env
	@echo "Applying migrations from $(MIGRATIONS_PATH)..."
	$(call run_with_env, migrate -path $(MIGRATIONS_PATH) up)

migrate-down: check_env
	@echo "Rolling back last migration from $(MIGRATIONS_PATH)..."
	$(call run_with_env, migrate -path $(MIGRATIONS_PATH) down 1) # down 1 rolls back one migration

migrate-down-all: check_env
	@echo "Rolling back ALL migrations from $(MIGRATIONS_PATH)..."
	$(call run_with_env, migrate -path $(MIGRATIONS_PATH) down -all)

migrate-version: check_env
	@echo "Checking migration version..."
	$(call run_with_env, migrate -path $(MIGRATIONS_PATH) version)

migrate-create: NAME = new_migration
migrate-create: check_env
	@echo "Creating new migration named $(NAME) in $(MIGRATIONS_PATH)..."
	$(call run_with_env, migrate create -ext sql -dir $(MIGRATIONS_PATH) -seq $(NAME))

.PHONY: check_env migrate-up migrate-down migrate-down-all migrate-version migrate-create

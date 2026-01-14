# Truth Layer Makefile

.PHONY: truth\:lint truth\:spec truth\:verify

TRUTH_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Lint truth layer specs for forbidden patterns
truth\:lint:
	cd $(TRUTH_DIR)/.. && ruby truth/lint/lint.rb

# Run truth layer specs
truth\:spec:
	@echo "Running truth specs..."
	cd $(TRUTH_DIR) && bundle exec rspec evaluations --format documentation

# Verify truth layer (lint + spec)
truth\:verify: truth\:lint truth\:spec
	@echo "Truth verification complete"

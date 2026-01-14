# Truth Layer Makefile

.PHONY: truth\:lint truth\:spec truth\:verify

TRUTH_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Lint truth layer specs for forbidden patterns
truth\:lint:
	cd $(TRUTH_DIR)/.. && ruby truth/lint/lint.rb

# Run truth layer specs (skips if no Gemfile)
truth\:spec:
	@if [ -f $(TRUTH_DIR)/Gemfile ]; then \
		echo "Running truth specs..."; \
		cd $(TRUTH_DIR) && bundle exec rspec evaluations --format documentation; \
	else \
		echo "Skipping specs (no Gemfile - add RSpec setup when ready)"; \
	fi

# Verify truth layer (lint + spec)
truth\:verify: truth\:lint truth\:spec
	@echo "Truth verification complete"

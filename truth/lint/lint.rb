# truth/lint/lint.rb

# Patterns that indicate implementation leakage or speculative language.
# These are calibrated to catch actual problems, not English words.
FORBIDDEN_PATTERNS = [
  # Framework references (truth must be implementation-agnostic)
  /\brails\b/i,          # "rails" but not "guardrails"
  /activerecord/i,
  /\bapp\//,             # Rails app/ directory paths
  /\bconfig\//,          # Rails config/ directory paths
  /views\//,             # MVC view directories (not English "view")

  # MVC layer terms (suggests implementation thinking)
  /\bcontroller\b/i,
  # Note: "model" removed - "data model", "domain model" are legitimate

  # Speculative language (truth must be normative)
  /\bTODO\b/i,
  /\bfor now\b/i,
  /\beventually\b/i,
  /\bmaybe\b/i,
  /\bshould\s+(be|have|probably|ideally|eventually)\b/i,  # "should be X" is speculative
  /\bmight\s+(be|have|need)\b/i,                          # "might need" is speculative
]

violations = []

# Skip the linter itself, contract validator, and vendored dependencies
EXCLUDED_PATTERNS = [
  %r{^truth/lint/lint\.rb$},
  %r{^truth/lint/contract_validator\.rb$},
  %r{^truth/vendor/},
]

Dir.glob("truth/**/*.{md,yml,rb,sql}").each do |file|
  next if EXCLUDED_PATTERNS.any? { |pattern| file.match?(pattern) }
  next if file.end_with?("README.md")      # READMEs are documentation, not specs
  next if file.end_with?("WORKFLOW.md")    # Workflow docs contain example code
  next if file.end_with?("now.md")         # Focus tracker is operational, not normative

  content = File.read(file)
  FORBIDDEN_PATTERNS.each do |pattern|
    if content.match?(pattern)
      violations << "#{file} contains forbidden pattern: #{pattern}"
    end
  end
end

if violations.any?
  puts "TRUTH LINT FAILED"
  puts violations.join("\n")
  exit 1
else
  puts "Truth lint passed"
end

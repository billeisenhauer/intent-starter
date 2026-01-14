# truth/lint/lint.rb

FORBIDDEN_PATTERNS = [
  /rails/i,
  /activerecord/i,
  /\bapp\//,
  /\bconfig\//,
  /\bcontroller\b/i,
  /\bmodel\b/i,
  /\bview\b/i,
  /\bTODO\b/i,
  /\bfor now\b/i,
  /\beventually\b/i,
  /\bmaybe\b/i,
  /\bshould\b/i
]

violations = []

# Skip the linter itself (contains patterns as definitions)
EXCLUDED_FILES = %w[truth/lint/lint.rb]

Dir.glob("truth/**/*.{md,yml,rb,sql}").each do |file|
  next if EXCLUDED_FILES.include?(file)

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


package config

import (
	"os"
	"strconv"
)

// Config holds application configuration.
type Config struct {
	DatabaseURL string
	Port        int
	Environment string
}

// Load reads configuration from environment variables.
func Load() *Config {
	port, _ := strconv.Atoi(getEnv("PORT", "3001"))

	return &Config{
		DatabaseURL: getEnv("DATABASE_URL", "postgres://postgres:postgres@localhost:5432/binge_watching_go"),
		Port:        port,
		Environment: getEnv("GO_ENV", "development"),
	}
}

// IsDevelopment returns true if running in development mode.
func (c *Config) IsDevelopment() bool {
	return c.Environment == "development"
}

// IsProduction returns true if running in production mode.
func (c *Config) IsProduction() bool {
	return c.Environment == "production"
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}

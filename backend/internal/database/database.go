package database

import (
	"context"
	"fmt"
	"log/slog" // Using structured logging
	"os"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"
)

// DB holds the database connection pool.
var DB *pgxpool.Pool

// Connect initializes the database connection pool.
func Connect() error {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		return fmt.Errorf("DATABASE_URL environment variable not set")
	}

	config, err := pgxpool.ParseConfig(databaseURL)
	if err != nil {
		return fmt.Errorf("unable to parse DATABASE_URL: %w", err)
	}

	// You can configure pool settings here if needed
	// config.MaxConns = 10
	// config.MinConns = 2
	// config.MaxConnLifetime = time.Hour
	// config.MaxConnIdleTime = time.Minute * 30
	// config.HealthCheckPeriod = time.Minute
	// config.ConnConfig.ConnectTimeout = time.Second * 5

	var pool *pgxpool.Pool
	// Retry connection a few times for resilience, e.g., during startup in orchestrated environments
	for i := 0; i < 5; i++ {
		pool, err = pgxpool.NewWithConfig(context.Background(), config)
		if err == nil {
			// Try to ping the database
			if err := pool.Ping(context.Background()); err == nil {
				DB = pool
				slog.Info("Successfully connected to PostgreSQL database.")
				return nil
			} else {
				slog.Warn("Failed to ping database", "attempt", i+1, "error", err)
				if pool != nil {
					pool.Close()
				}
			}
		} else {
			slog.Warn("Failed to create connection pool", "attempt", i+1, "error", err)
		}
		slog.Info("Retrying database connection in 5 seconds...")
		time.Sleep(5 * second)
	}

	return fmt.Errorf("unable to connect to database after multiple retries: %w", err)
}

// Close closes the database connection pool.
// It's good practice to call this on application shutdown.
func Close() {
	if DB != nil {
		slog.Info("Closing database connection pool.")
		DB.Close()
	}
}

// GetDB returns the current database connection pool.
// This function can be used by other packages to access the pool.
func GetDB() *pgxpool.Pool {
	if DB == nil {
		slog.Error("Database connection pool is not initialized. Call database.Connect() first.")
		// Or panic, depending on how critical it is
		return nil
	}
	return DB
}

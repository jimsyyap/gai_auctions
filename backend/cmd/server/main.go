package main

import (
	"context" // Required for graceful shutdown
	"log/slog"
	"net/http"
	"os"
	"os/signal" // Required for graceful shutdown
	"syscall"   // Required for graceful shutdown
	"time"      // Required for graceful shutdown

	"github.com/jimsyyap/backend/internal/database" // <-- IMPORT YOUR DATABASE PACKAGE (replace YOUR_MODULE_PATH)

	"github.com/joho/godotenv"
	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func main() {
	_ = godotenv.Load()

	// Logger setup (as previously defined)
	var logger *slog.Logger
	appEnv := os.Getenv("APP_ENV")
	logLevel := slog.LevelInfo
	if appEnv == "development" {
		logger = slog.New(slog.NewTextHandler(os.Stderr, &slog.HandlerOptions{Level: slog.LevelDebug}))
		logLevel = slog.LevelDebug
	} else {
		logger = slog.New(slog.NewJSONHandler(os.Stderr, &slog.HandlerOptions{Level: logLevel}))
	}
	slog.SetDefault(logger)
	slog.Info("Logger initialized", "level", logLevel.String(), "environment", appEnv)

	// --- Connect to Database ---
	if err := database.Connect(); err != nil { // <-- CONNECT HERE
		slog.Error("Failed to connect to database", "error", err)
		os.Exit(1) // Exit if DB connection fails
	}
	defer database.Close() // Ensure DB connection is closed when main function exits

	e := echo.New()

	// Middleware (as previously defined)
	e.Use(middleware.Recover())
	e.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{ /* ... */ })) // Your existing config
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{ /* ... */ }))                   // Your existing config

	e.GET("/", func(c echo.Context) error {
		// Test DB connection by pinging (optional here, already done in Connect)
		// if err := database.DB.Ping(context.Background()); err != nil {
		//  slog.Error("Failed to ping database from handler", "error", err)
		// 	return c.String(http.StatusInternalServerError, "DB connection error")
		// }
		slog.Info("Root handler called, DB should be connected.")
		return c.String(http.StatusOK, "Welcome to the Auction Platform API! DB Connected.")
	})

	// TODO: API v1 routes (e.g., apiV1 := e.Group("/api/v1"))

	serverPort := os.Getenv("SERVER_PORT")
	if serverPort == "" {
		serverPort = "8080"
	}
	addr := ":" + serverPort

	// Start server in a goroutine so that it doesn't block.
	go func() {
		slog.Info("Starting server", "address", addr)
		if err := e.Start(addr); err != nil && err != http.ErrServerClosed {
			slog.Error("Server failed to start", "error", err)
			e.Close() // Ensure echo cleanup runs
			os.Exit(1)
		}
	}()

	// Graceful Shutdown Setup
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit // Block until a signal is received

	slog.Info("Shutting down server...")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second) // Context for shutdown
	defer cancel()

	if err := e.Shutdown(ctx); err != nil {
		slog.Error("Server shutdown failed", "error", err)
		// os.Exit(1) // Optionally force exit
	}
	slog.Info("Server gracefully shut down.")
}

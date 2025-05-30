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
	//e.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{ /* ... */ })) // Your existing config
	e.Use(middleware.RequestLoggerWithConfig(middleware.RequestLoggerConfig{
		LogStatus:   true,
		LogURI:      true,
		LogMethod:   true,
		LogLatency:  true,
		LogRemoteIP: true,
		LogError:    true,
		HandleError: true, // Required to log errors that occur before reaching the handler
		LogValuesFunc: func(c echo.Context, v middleware.RequestLoggerValues) error { // <-- THIS IS THE IMPORTANT PART
			// Log non-error requests at Info level
			level := slog.LevelInfo
			attrs := []slog.Attr{
				slog.String("ip", v.RemoteIP),
				slog.String("method", v.Method),
				slog.String("uri", v.URI),
				slog.Int("status", v.Status),
				slog.Duration("latency", v.Latency),
			}

			// Log error requests at Error level and include the error message
			if v.Error != nil {
				level = slog.LevelError
				attrs = append(attrs, slog.String("error", v.Error.Error()))
			}

			// Use the globally set logger (or pass your 'logger' variable if it's in scope)
			slog.Default().LogAttrs(c.Request().Context(), level, "HTTP request", attrs...)
			// If your 'logger' variable from main is directly accessible here, you could use:
			// logger.LogAttrs(c.Request().Context(), level, "HTTP request", attrs...)
			return nil
		}, // <-- MAKE SURE THIS FUNCTION AND THE COMMA ARE PRESENT
	}))

	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{ /* ... */ })) // Your existing config

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

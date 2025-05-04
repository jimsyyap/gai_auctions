# Auction Platform - Backend

This directory contains the Go backend service for the auction platform.

## Tech Stack

* **Language:** Go (Golang)
* **Web Framework:** [Choose one, e.g., Gin, Echo, Chi - TBD]
* **Database:** PostgreSQL
* **ORM/DB Library:** [Choose one, e.g., GORM, sqlx, pgx - TBD]
* **WebSockets:** github.com/gorilla/websocket
* **Authentication:** JWT (e.g., github.com/golang-jwt/jwt/v5)
* **Migrations:** [Choose one, e.g., golang-migrate/migrate, goose - TBD]

## Project Structure

* `cmd/server/main.go`: Application entry point.
* `internal/`: All core application logic.
    * `api/`: HTTP handlers.
    * `store/`: Database interaction logic (repositories).
    * `models/`: Data structures.
    * `websocket/`: WebSocket hub and connection management.
    * `auth/`: Authentication services.
    * `config/`: Configuration loading.
    * `database/`: Database setup.
    * `middleware/`: HTTP middleware.
    * `*/`: Domain-specific logic (user, item, bid, category).
* `migrations/`: Database migration files.
* `go.mod`/`go.sum`: Go module files.
* `.env.example`: Example environment variables needed.

## Setup & Running

1.  **Install Go:** Ensure you have Go installed (version 1.18+ recommended).
2.  **Database:** Set up a PostgreSQL database.
3.  **Configuration:**
    * Copy `.env.example` to `.env`.
    * Fill in the necessary environment variables in `.env` (database connection string, JWT secret, server port, etc.).
4.  **Install Dependencies:**
    ```bash
    go mod download
    ```
5.  **Run Migrations:** (Using your chosen migration tool)
    ```bash
    # Example using golang-migrate/migrate
    # migrate -path migrations -database "$DATABASE_URL" up
    ```
6.  **Run the Server:**
    ```bash
    go run cmd/server/main.go
    ```
    Alternatively, build the binary:
    ```bash
    go build -o server cmd/server/main.go
    ./server
    ```

## API Endpoints

*(To be defined - Will list the RESTful API endpoints here)*

## Environment Variables

*(List required environment variables here, e.g., DATABASE_URL, JWT_SECRET_KEY, SERVER_PORT)*

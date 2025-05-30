-- migrations/000001_create_users_table.up.sql
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Create an index on email for faster lookups, essential for login
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Optional: Create an index on username if it's frequently used for lookups
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);

-- Function and Trigger to automatically update 'updated_at' timestamp
-- We'll create this once and it can be used by other tables too.
-- If you plan to have this in a separate, earlier migration, you can remove it from here.
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_timestamp_users
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

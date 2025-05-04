-- Enable UUID generation if you prefer UUIDs over SERIAL for primary keys
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users Table: Stores information about registered users
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    -- id UUID PRIMARY KEY DEFAULT uuid_generate_v4(), -- Alternative using UUID
    email VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(50) UNIQUE, -- Optional username
    password_hash VARCHAR(255) NOT NULL, -- Store hashed passwords only!
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster email lookup (essential for login)
CREATE INDEX idx_users_email ON users(email);
-- Index for faster username lookup (if used frequently)
CREATE INDEX idx_users_username ON users(username);


-- Categories Table: Stores item categories (can be hierarchical)
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) UNIQUE NOT NULL, -- URL-friendly identifier
    description TEXT,
    parent_id INTEGER REFERENCES categories(id) ON DELETE SET NULL, -- For subcategories
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index for faster slug lookup
CREATE INDEX idx_categories_slug ON categories(slug);
-- Index for finding subcategories
CREATE INDEX idx_categories_parent_id ON categories(parent_id);


-- Items Table: Stores details about items listed for auction or sale
CREATE TYPE item_status AS ENUM ('draft', 'active', 'sold', 'expired', 'cancelled'); -- Define allowed statuses

CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- The seller
    category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT, -- Don't delete category if items exist
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    start_price DECIMAL(12, 2) NOT NULL CHECK (start_price >= 0), -- Starting bid price
    current_price DECIMAL(12, 2) NOT NULL CHECK (current_price >= 0), -- Highest current bid or starting price
    reserve_price DECIMAL(12, 2) CHECK (reserve_price IS NULL OR reserve_price > start_price), -- Optional minimum selling price
    buy_now_price DECIMAL(12, 2) CHECK (buy_now_price IS NULL OR buy_now_price > start_price), -- Optional instant purchase price
    start_time TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP, -- When the listing goes live
    end_time TIMESTAMPTZ NOT NULL, -- Auction end time
    status item_status NOT NULL DEFAULT 'active', -- Current status of the listing
    winner_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL, -- Who won/bought the item
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ensure end time is after start time
    CONSTRAINT chk_end_time CHECK (end_time > start_time)
    -- Consider adding a constraint for buy_now_price vs reserve_price if needed
    -- CONSTRAINT chk_buy_now_vs_reserve CHECK (buy_now_price IS NULL OR reserve_price IS NULL OR buy_now_price > reserve_price)
);

-- Indexes for common query patterns
CREATE INDEX idx_items_user_id ON items(user_id);
CREATE INDEX idx_items_category_id ON items(category_id);
CREATE INDEX idx_items_end_time ON items(end_time);
CREATE INDEX idx_items_status ON items(status);
CREATE INDEX idx_items_winner_user_id ON items(winner_user_id);
-- Consider a full-text search index for title/description
-- CREATE INDEX idx_items_search ON items USING GIN (to_tsvector('english', title || ' ' || description));


-- Item Images Table: Stores multiple images associated with an item
CREATE TABLE item_images (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE, -- Link to the item
    image_url VARCHAR(512) NOT NULL, -- URL of the image (e.g., S3 path)
    alt_text VARCHAR(255), -- Alt text for accessibility
    is_primary BOOLEAN NOT NULL DEFAULT FALSE, -- Indicates the main display image
    uploaded_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Index for retrieving images for a specific item
CREATE INDEX idx_item_images_item_id ON item_images(item_id);
-- Ensure only one primary image per item
CREATE UNIQUE INDEX uq_item_images_primary ON item_images(item_id, is_primary) WHERE is_primary = TRUE;


-- Bids Table: Stores individual bids placed on items
CREATE TABLE bids (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE, -- Item being bid on
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- User placing the bid
    amount DECIMAL(12, 2) NOT NULL, -- The amount of the bid
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ensure bid amount is positive
    CONSTRAINT chk_bid_amount CHECK (amount > 0)
    -- Prevent a user from bidding on their own item (optional, can be handled in application logic too)
    -- CONSTRAINT chk_bidder_is_not_seller CHECK (user_id != (SELECT user_id FROM items WHERE id = item_id)) -- This might be complex/slow, better in app logic
);

-- Indexes for querying bids
CREATE INDEX idx_bids_item_id ON bids(item_id);
CREATE INDEX idx_bids_user_id ON bids(user_id);
-- Index for finding the highest bid quickly
CREATE INDEX idx_bids_item_amount_created ON bids(item_id, amount DESC, created_at ASC);


-- Watchlist Table: Many-to-many relationship for users watching items
CREATE TABLE watchlist (
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    item_id INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, item_id) -- Ensures a user watches an item only once
);

-- Index for finding items watched by a user
CREATE INDEX idx_watchlist_user_id ON watchlist(user_id);
-- Index for finding users watching an item
CREATE INDEX idx_watchlist_item_id ON watchlist(item_id);


-- Feedback Table: Stores ratings and comments between buyers and sellers
CREATE TYPE feedback_type AS ENUM ('buyer_to_seller', 'seller_to_buyer');

CREATE TABLE feedback (
    id SERIAL PRIMARY KEY,
    item_id INTEGER NOT NULL REFERENCES items(id) ON DELETE CASCADE, -- The related transaction/item
    reviewer_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- User leaving the feedback
    reviewed_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- User receiving the feedback
    rating SMALLINT NOT NULL, -- e.g., 1 to 5
    comment TEXT,
    feedback_type feedback_type NOT NULL, -- Direction of the feedback
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Ensure rating is within a valid range
    CONSTRAINT chk_rating_range CHECK (rating >= 1 AND rating <= 5),
    -- Ensure a user doesn't review themselves for a transaction
    CONSTRAINT chk_reviewer_not_reviewed CHECK (reviewer_user_id != reviewed_user_id),
    -- Ensure one feedback entry per reviewer per item transaction direction
    CONSTRAINT uq_feedback_item_reviewer UNIQUE (item_id, reviewer_user_id, feedback_type)
);

-- Indexes for querying feedback
CREATE INDEX idx_feedback_item_id ON feedback(item_id);
CREATE INDEX idx_feedback_reviewer_user_id ON feedback(reviewer_user_id);
CREATE INDEX idx_feedback_reviewed_user_id ON feedback(reviewed_user_id);


-- Function and Trigger to automatically update 'updated_at' timestamp
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply the trigger to tables that have 'updated_at'
CREATE TRIGGER set_timestamp_users
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

CREATE TRIGGER set_timestamp_items
BEFORE UPDATE ON items
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();

-- Add triggers for other tables with updated_at if needed (e.g., profiles)


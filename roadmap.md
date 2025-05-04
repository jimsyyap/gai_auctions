Auction Platform Project Roadmap
This roadmap outlines the key phases and major tasks involved in developing the auction platform using Vue.js, Go, and PostgreSQL.

Phase 0: Foundation & Setup (Estimated: 1-2 Sprints / Weeks)

Goal: Establish the project structure, development environment, and basic tooling.

Tasks:
    [x] Initialize Git repository with main branches.

    [x] Set up Go backend project:

    [x] Create folder structure (as defined previously).

    [ ] Initialize Go modules (go.mod).

    [ ] Choose and set up web framework (e.g., Gin, Echo).

    [ ] Implement basic configuration loading (.env).

    [ ] Set up basic logging.

    [ ] Set up Vue.js frontend project:

    [ ] Initialize project using Vite (npm create vue@latest).

    [ ] Create folder structure (as defined previously).

    [ ] Set up Vue Router.

    [ ] Set up State Management (Pinia).

    [ ] Choose and integrate UI framework/library (e.g., Tailwind CSS).

    [ ] Set up PostgreSQL database:

    [ ] Create the database instance.

    [ ] Set up database migration tool (e.g., golang-migrate/migrate, goose).

    [ ] Implement initial database schema migrations (Users, Categories tables).

    [ ] Implement basic database connection logic in Go backend.

    [ ] Define initial CI/CD pipeline (optional but recommended).

Phase 1: Core User & Listing Functionality (Estimated: 3-4 Sprints / Weeks)
Goal: Allow users to register, log in, and create/view basic item listings.

Backend:

    [ ] Implement User Registration API endpoint (/auth/register) with password hashing.

    [ ] Implement User Login API endpoint (/auth/login) with JWT generation.

    [ ] Implement JWT authentication middleware.

    [ ] Implement Get Current User API endpoint (/auth/me).

    [ ] Implement Get User Profile API endpoint (/users/{userId}).

    [ ] Implement Update User Profile API endpoint (/users/me).

    [ ] Implement Category CRUD API endpoints (or seed data script).

    [ ] Implement Create Item Listing API endpoint (/items) including image upload handling (to local storage or basic cloud setup).

    [ ] Implement Get Item Details API endpoint (/items/{itemId}).

    [ ] Implement List/Search Items API endpoint (/items) with basic filtering (category, search term).

    [ ] Implement List User's Items API endpoint (/users/me/items).

    [ ] Create database migrations for Items, ItemImages tables.

Frontend:

    [ ] Create Registration page/form.

    [ ] Create Login page/form.

    [ ] Implement auth state management (Pinia store).

    [ ] Implement protected routes (using Vue Router guards).

    [ ] Create User Profile view/edit page.

    [ ] Create "Create New Listing" page/form with image upload UI.

    [ ] Create Item Detail page.

    [ ] Create Homepage/Browse Listings page with search/filter inputs.

    [ ] Create "My Listings" page.

    [ ] Implement API service layer (e.g., using Axios) for all endpoints.

Phase 2: Bidding & Auction Mechanics (Estimated: 3-4 Sprints / Weeks)

Goal: Implement the core auction functionality, including bidding, buy now, and auction closing.

Backend:

    [ ] Implement Place Bid API endpoint (/items/{itemId}/bids) with validation (bid amount, auction status, not own item).

    [ ] Implement logic to update current_price on the item when a valid bid is placed.

    [ ] Implement Get Bids for Item API endpoint (/items/{itemId}/bids).

    [ ] Implement "Buy Now" logic (likely integrated into Get Item Details or a separate endpoint, updates item status to 'sold').

    [ ] Implement Reserve Price logic checks (during bidding, during closing).

    [ ] Implement basic Proxy Bidding logic within the Place Bid endpoint.

    [ ] Create a background task/job scheduler (e.g., using Go cron library) to periodically check for ended auctions.

    [ ] Implement Auction Closing logic (determine winner based on bids/reserve, update item status, set winner_user_id).

    [ ] Create database migrations for Bids table.

Frontend:

    [ ] Add "Place Bid" input/button to Item Detail page.

    [ ] Add "Buy Now" button to Item Detail page (conditional).

    [ ] Display current price, number of bids, time remaining prominently on Item Detail page.

    [ ] Display Bid History section on Item Detail page.

    [ ] Create "My Bids" page (listing items the user has bid on).

    [ ] Update relevant API service calls.

Phase 3: Real-time Updates & Polish (Estimated: 2-3 Sprints / Weeks)

Goal: Enhance user experience with real-time bid updates and add watchlist/feedback features.

Backend:

    [ ] Set up WebSocket server (/ws endpoint).

    [ ] Implement WebSocket connection management (handling connect/disconnect).

    [ ] Implement WebSocket message broadcasting (e.g., when a new bid is placed).

    [ ] Implement Watchlist API endpoints (/watchlist, POST/DELETE /watchlist/{itemId}).

    [ ] Implement Feedback API endpoints (/feedback, /users/{userId}/feedback).

    [ ] Create database migrations for Watchlist, Feedback tables.

Frontend:

    [ ] Implement WebSocket client connection.

    [ ] Update Item Detail page to receive and display real-time bid updates (current price, bid history).

    [ ] Implement "Add to Watchlist" / "Remove from Watchlist" buttons/logic.

    [ ] Create Watchlist page.

    [ ] Implement "Leave Feedback" UI (e.g., on a completed transaction page/section).

    [ ] Display user feedback scores/details on User Profile pages.

    [ ] General UI/UX refinement and bug fixing.

Phase 4: Post-MVP Features & Deployment (Ongoing)

Goal: Add valuable features beyond the core MVP and prepare for production.

    [ ] Implement Classifieds-style listings (if desired).

    [ ] Integrate a Payment Gateway (Stripe, PayPal, etc.).

    [ ] Implement advanced search/filtering options.

    [ ] Develop an Admin Panel for moderation and management.

    [ ] Implement a more robust Notification system (email notifications).

    [ ] Containerize applications (Docker).

    [ ] Set up production infrastructure (Cloud hosting, managed database, CDN for images).

    [ ] Implement monitoring, alerting, and logging for production.

    [ ] Performance optimization (database query tuning, frontend bundle size).

    [ ] Security hardening and testing.

This roadmap provides a structured approach. The phases can overlap, and priorities might shift based on feedback and testing. Remember to break down tasks within each phase into smaller, manageable units for development sprints.

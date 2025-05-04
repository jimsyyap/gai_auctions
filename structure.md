auction-platform/
│
├── backend/
│   ├── cmd/
│   │   └── server/
│   │       └── main.go          # Main application entry point
│   ├── internal/                # Private application logic
│   │   ├── api/                 # API route handlers/controllers
│   │   ├── auth/                # Authentication logic (JWT, sessions)
│   │   ├── bid/                 # Bidding domain logic
│   │   ├── category/            # Category domain logic
│   │   ├── config/              # Configuration loading (env vars, files)
│   │   ├── database/            # Database connection, setup, migrations setup
│   │   ├── item/                # Item listing domain logic
│   │   ├── middleware/          # Request middleware (logging, auth checks)
│   │   ├── models/              # Database model structs (can also live within domains)
│   │   ├── store/               # Database interaction logic (repositories)
│   │   ├── user/                # User domain logic
│   │   └── websocket/           # WebSocket connection management & hub
│   ├── migrations/              # SQL migration files (e.g., using migrate or goose)
│   ├── go.mod                   # Go module definition
│   ├── go.sum                   # Go module checksums
│   ├── .env.example             # Example environment variables file
│   ├── .gitignore               # Git ignore rules for Go
│   └── README.md                # Backend specific documentation
│
├── frontend/
│   ├── public/                  # Static assets directly served
│   │   └── index.html           # Base HTML file
│   ├── src/                     # Main Vue application source
│   │   ├── assets/              # Static assets (images, fonts, CSS) processed by build tool
│   │   ├── components/          # Reusable UI components (e.g., Button, Card)
│   │   ├── router/              # Vue Router configuration (index.js)
│   │   ├── services/ (or api/)  # API communication layer (e.g., axios wrappers)
│   │   ├── stores/ (or store/)  # State management (Pinia or Vuex)
│   │   ├── views/ (or pages/)   # Page-level components mapped to routes
│   │   ├── App.vue              # Root Vue component
│   │   └── main.js (or main.ts) # Vue application entry point
│   ├── .gitignore               # Git ignore rules for Node/Vue
│   ├── index.html               # Template HTML file (often same as public/index.html)
│   ├── package.json             # Node project dependencies and scripts
│   ├── vite.config.js           # Build tool configuration (if using Vite)
│   └── README.md                # Frontend specific documentation
│
└── README.md                    # Root project documentation

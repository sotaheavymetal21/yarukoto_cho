# Yarukoto Cho

A modern task management application built with Ruby on Rails.

## Tech Stack

- **Framework**: Ruby on Rails 7.2.3
- **Language**: Ruby 3.3.10
- **Database**: PostgreSQL
- **Cache/Jobs**: Redis + Sidekiq
- **Frontend**: Hotwire (Turbo + Stimulus) + Tailwind CSS
- **Authentication**: Devise with OAuth (Google, GitHub)
- **Authorization**: Pundit
- **Testing**: RSpec + FactoryBot + Capybara

## Requirements

- Ruby 3.3.10
- Node.js (LTS)
- PostgreSQL 16+
- Redis 7+

## Setup

```bash
# Clone the repository
git clone <repository-url>
cd yarukoto_cho

# Install dependencies
bundle install
npm install

# Setup environment variables
cp .env.example .env
# Edit .env with your configuration

# Setup database
bin/rails db:create db:migrate db:seed

# Start the development server
bin/dev
```

## Development Commands

### Running the Application

```bash
bin/dev                 # Start development server (Rails + assets)
bin/rails server        # Rails server only
```

### Testing

```bash
bundle exec rspec               # Run all tests
bundle exec rspec spec/models   # Run model tests only
COVERAGE=true bundle exec rspec # Run with coverage report
```

### Linting & Security

```bash
bin/rubocop             # Run RuboCop linter
bin/rubocop -a          # Auto-fix offenses
bin/brakeman --no-pager # Security scan
```

### Database

```bash
bin/rails db:migrate    # Run migrations
bin/rails db:seed       # Seed database
bin/rails db:reset      # Drop, create, migrate, seed
```

### Background Jobs

```bash
bundle exec sidekiq     # Start Sidekiq worker
```

## Directory Structure

```
yarukoto_cho/
├── app/
│   ├── controllers/    # Request handlers
│   ├── models/         # Business logic
│   ├── policies/       # Authorization policies (Pundit)
│   ├── views/          # Templates
│   └── javascript/     # Stimulus controllers
├── config/
│   ├── routes.rb       # URL routing
│   └── initializers/   # App configuration
├── db/
│   ├── migrate/        # Database migrations
│   └── schema.rb       # Current schema
├── spec/
│   ├── factories/      # FactoryBot factories
│   ├── models/         # Model specs
│   └── support/        # Test helpers
└── .github/
    └── workflows/      # CI/CD configuration
```

## OAuth Setup

### Google OAuth

1. Create a project in [Google Cloud Console](https://console.cloud.google.com)
2. Enable Google+ API
3. Create OAuth 2.0 credentials
4. Add callback URL: `http://localhost:3000/users/auth/google_oauth2/callback`
5. Set `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET` in `.env`

### GitHub OAuth

1. Create an OAuth App in [GitHub Developer Settings](https://github.com/settings/developers)
2. Set callback URL: `http://localhost:3000/users/auth/github/callback`
3. Set `GITHUB_CLIENT_ID` and `GITHUB_CLIENT_SECRET` in `.env`

## License

MIT

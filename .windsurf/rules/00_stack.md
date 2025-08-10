---
trigger: always_on
---

STACK:
- Laravel (latest stable/LTS)
- Laravel + Livewire (Blade only, NO Vue/React/Inertia)
- Local: Herd FREE (Windows) + SQLite (database/database.sqlite)
- Deploy: Laravel Cloud (push-to-deploy, PostgreSQL)

HERD FREE LIMITS:
Available: PHP, Nginx, DNS, Node.js, SQLite
Not available: mail sending, queues/workers, Horizon, MySQL/Postgres local, Xdebug, Redis, broadcasting.
If a feature needs these → warn user: Herd Pro required. Offer fakes (Mail::fake, Queue::fake, etc.).

RULES:
- Always keep local DB SQLite; Postgres only on Laravel Cloud.
- No Docker, WSL, or alternate PaaS unless explicitly asked.
- .env is fully managed by assistant (generate APP_KEY, set SQLite path, prompt for secrets).
- Use Pest tests; RefreshDatabase; SQLite in-memory for tests.
- Build with Vite; prefer first-party Laravel packages.

DEPLOYMENT:
- On push: run migrations (`php artisan migrate --force`), build assets, set Cloud env vars.
- Mirror local `.env` to Cloud (no secrets printed).

DELIVERABLES:
- Provide exact file paths, ready-to-paste code, and required commands.
- Never print real secrets; mask when confirming.
---
trigger: always_on
---

GOAL:
- User is a beginner; they never edit `.env` manually.
- The assistant creates, edits, and maintains `.env` for all features.

RESPONSIBILITIES:
- Always ensure `.env` has:
  - APP_KEY (php artisan key:generate --ansi if missing)
  - DB_CONNECTION=sqlite (local), DB_DATABASE=./database/database.sqlite
  - Any API keys/secrets required by features
- When a feature needs a new secret:
  1) Explain to the user what is needed and why
  2) Prompt for the value (masked)
  3) Write/update `.env` immediately
- Use placeholders if value is not yet available, mark with #TODO

RULES:
- Keep `.env.example` in sync with `.env` (placeholders for secrets)
- Never expose real secrets in logs/output; mask when confirming
- For Laravel Cloud: ensure Cloud env vars mirror local `.env` (without printing secrets)

ERROR HANDLING:
- If missing value causes failure → prompt user, update `.env`, re-run setup/tests
- Overwrite incorrect values only with user confirmation

DELIVERABLES:
- Show `.env` changes with secrets masked
- Provide updated `.env.example` whenever `.env` changes
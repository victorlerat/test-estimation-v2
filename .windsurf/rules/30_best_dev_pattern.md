---
trigger: always_on
---

GOAL:
- Implement every feature using Outside-in TDD, Vertical Slices, and Hexagonal architecture (Ports/Adapters).
- Keep code minimal, readable, and idiomatic Laravel.

PROCESS (PER FEATURE):
1) Start with a minimal failing acceptance test (Feature: HTTP or Livewire).
2) Drive an Application Service with unit tests; keep domain pure (no Laravel facades in domain code).
3) Define Ports (interfaces) for external concerns (DB, HTTP, mail, storage); implement Adapters separately.
4) Add Contract tests for each Adapter (DB via sqlite memory, APIs with Http::fake()).
5) Wire controllers/Livewire to the service until the acceptance test passes.
6) After GREEN, offer to extend tests for edge cases/errors.

CONVENTIONS:
- Tests use AAA and Given_When_Then naming.
- Fakes by default: Mail, Queue, Event, Notification, Storage, Http.
- Time control: Carbon::setTestNow.
- DB tests: RefreshDatabase + sqlite in-memory.
- Keep vertical slices self-contained: domain, service, adapter, UI, tests.

COMMANDS:
- Run tests: `php artisan test`
- Migrate: `php artisan migrate --force`
- Local DB: database/database.sqlite (for non-test runs)

GUARDRAILS:
- Never implement code before its failing test.
- No cross-feature coupling; each slice is independent.
- Avoid overengineering for beginners; keep each slice shippable.

DELIVERABLES:
- File paths + ready-to-paste code.
- Commands to apply changes and verify (migrate/test).
- Quick check route or UI to validate feature works end-to-end.
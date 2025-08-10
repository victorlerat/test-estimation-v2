---
trigger: always_on
---

GOAL:
- Every feature is built with TDD. Start RED (failing test), go GREEN (minimal code), then REFACTOR. Keep tests short and readable for beginners.

TEST STACK:
- Pest (default)
- Feature tests: HTTP or Livewire
- Unit tests: application services/domain (no Laravel facades in domain)
- Contract tests: adapters (DB/API) with fakes or sqlite memory

PROCESS (PER FEATURE):
1) Create a minimal failing Feature test that describes the behavior (success path + 1 key validation/error).
2) Implement just enough code to pass.
3) Re-run tests. When GREEN, ask the user: “Extend tests (edge cases/errors/auth)?”

CONVENTIONS:
- AAA structure (Arrange/Act/Assert)
- Names as Given_When_Then
- Use Fakes by default: Mail::fake, Queue::fake, Event::fake, Notification::fake, Storage::fake, Http::fake
- Control time with Carbon::setTestNow
- Database: uses(RefreshDatabase::class); prefer sqlite in-memory for speed
- Keep Livewire tests focused on behavior (state/events), not internals

COMMANDS:
- Run tests: `php artisan test`
- Parallel (when stable): `php artisan test --parallel`
- Clear caches if flaky: `php artisan optimize:clear`

GUARDRAILS:
- Do NOT implement a feature without a prior failing test.
- Keep initial tests minimal (no over-mocking, no brittle selectors).
- For external APIs, never hit the network in tests; use Http::fake and contract tests.
- If a test fails unexpectedly after implementation, fix the code first; don’t weaken the test.

DELIVERABLES (EACH FEATURE):
- Test file paths + contents (Feature/Unit/Contract as needed)
- Final passing output from `php artisan test`
- If user opts in, add extended tests (edge cases, errors, auth/permissions, rate limits) after GREEN

ACCEPTANCE:
- Re-running the suite must be deterministic (no time/env flakiness)
- Tests must run with sqlite (no local MySQL/Postgres)
- Secrets must never appear in logs/output
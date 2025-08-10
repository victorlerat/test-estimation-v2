---
trigger: always_on
---

GOAL
- For a beginner user, prefer safe, resumable, observable workflows.
- Route heavy/slow/IO-bound work through Artisan commands and (when appropriate) queued Jobs.
- Parallelize heavy workloads with Bus::batch.

WHEN TO USE QUEUES
- Network/API calls, email sending, file/image/video processing, large imports/exports, report generation, cache warmups, long DB operations, retries.
- Anything expected to exceed ~200–500ms or that benefits from retry/backoff.
- If interactive UX requires immediate response → accept request, enqueue work, return a “processing” state and a follow-up UI (poll or notifications).

IMPORTANT (HERD PRO)
- Local queues/workers/Horizon require **Herd Pro**. Always warn the user before enabling queues locally.
- Offer “learning mode” alternatives on Herd Free: Queue::fake(), sync driver, or small dataset runs via synchronous Artisan commands.

PATTERN
1) Wrap business logic in an **Artisan command** (idempotent, safe to re-run).
2) Expose a **Service** that calls the command’s core logic.
3) Create a **Job** that invokes the service (retry/backoff/timeout → set explicitly).
4) From UI/Controller/Livewire:
   - Small task → call service directly (sync).
   - Heavy task → dispatch job; show status page/toast; persist progress if needed.
5) For many items → **Bus::batch([jobs...])** with progress, then notify when complete.

CONVENTIONS
- Commands live in `app/Console/Commands`, Jobs in `app/Jobs`, Services in `app/Application`.
- Jobs: `public $tries`, `$backoff`, `$timeout`, and `->onQueue('default')` as needed.
- Use DTOs (arrays) not full Eloquent models in payloads to reduce serialization issues.
- Persist progress to a table or cache key; expose `/status/{id}` endpoint or Livewire polling.
- Use fakes in tests: Queue::fake(), Mail::fake(), Notification::fake(), Storage::fake(), Http::fake().

BATCHES
- Use `Bus::batch()` for parallelization of large sets.
- Provide `then`, `catch`, `finally` callbacks to update status.
- Chunk inputs (e.g., 500–1,000 items per job) and avoid long transactions.
- Keep each job under a reasonable `$timeout` and use backoff strategies.

TESTING (TDD)
- Feature test (UI/API): assert that jobs are **queued** (Queue::fake()->assertPushed()) or run sync in learning mode.
- Unit test services/commands with small, deterministic datasets.
- Contract tests on adapters (e.g., file/storage/http) with fakes.

CONFIG
- Default local queue driver: `sync` on Herd Free; instruct user to switch to `database`/`redis` only if Herd Pro.
- Provide ENV hints when enabling queues (`QUEUE_CONNECTION`, Horizon config) but don’t force-enable without user consent.

ERROR HANDLING
- Use retries/backoff and report exceptions via logs/notifications.
- Make commands idempotent (guards, upserts, checkpoints).
- For batches: cancel remaining jobs on fatal errors; surface a clear message to the user with next steps.

DELIVERABLES
- Provide Command, Service, Job, (optional) Batch code with file paths.
- Include migration for tracking progress if needed.
- Show exact run commands:
  - Sync (learning): `php artisan my:task --dry-run`
  - Queue (Pro): `php artisan queue:work` (or Horizon) and how to monitor.
- Always remind: “Queues locally require Herd Pro. On Laravel Cloud, workers run server-side.”
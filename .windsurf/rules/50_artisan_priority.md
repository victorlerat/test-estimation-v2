---
trigger: always_on
---

GOAL:
- Always prefer existing Laravel Artisan commands for generating, inspecting, or managing application code/config before manually writing files or code.

PRIORITY USAGE:
- For scaffolding models, controllers, Livewire components, migrations, factories, tests → use `php artisan make:*` commands.
- For listing or inspecting app state (routes, config, cache, migrations, queues) → use Artisan read commands (`php artisan route:list`, `php artisan config:cache`, etc.).
- For DB changes → prefer `php artisan migrate`, `php artisan migrate:fresh`, `php artisan db:seed` over manual SQL.
- For auth/UI setup → use official installers (`php artisan breeze:install livewire`).

BENEFITS:
- Ensures consistency with Laravel conventions
- Reduces manual errors and boilerplate drift
- Makes generated code match Laravel’s structure and naming

RULES:
- Before writing code manually, check if an Artisan command exists for the task.
- If yes, run the command and then adapt output if needed.
- If no, and manual code is required, document why no command was used.
- When user asks for a feature that matches an Artisan generator, suggest the command instead of writing everything from scratch.

COMMANDS TO PRIORITIZE (non-exhaustive):
- make:model, make:controller, make:livewire, make:migration, make:factory, make:test
- make:seeder, make:event, make:listener, make:job, make:command
- route:list, migrate, migrate:fresh, migrate:rollback, db:seed
- storage:link, queue:work, horizon, optimize:clear

DELIVERABLES:
- Always show the exact Artisan command first, then the resulting code changes (if applicable).
- Indicate where files were created and next steps (e.g., register route, update view).
- Prefer chaining flags to reduce steps (e.g., `php artisan make:model Post -mcr`).
# Laravel + Livewire Starter Kit

## Quick Start (Windows + Herd)

1. Clone this repository
2. Double-click `setup.bat` (or right-click `setup.ps1` → Run with PowerShell)
3. Open the app at your Herd domain (e.g. `https://<folder-name>.test`), register/login, then create your first resource

```bat
powershell -ExecutionPolicy Bypass -File setup.ps1 -CI
```

The setup script will:

- Configure `.env` and generate `APP_KEY`
- Use SQLite at `database/database.sqlite`
- Install PHP/Node dependencies and run migrations
- Optionally prompt for API keys (masked)
- Ready to use with Laravel Herd at `https://<folder-name>.test` (based on your project folder name)

## Troubleshooting

- Herd not found / PHP missing: Install Laravel Herd and ensure PHP/Composer are in PATH.
- npm missing: Frontend build is skipped; install Node.js to build assets later.
- Migration error: Confirm `database/database.sqlite` exists and is writeable. Run `php artisan optimize:clear` and re-run `setup.ps1`.
 - DNS/URL not resolving: Open the Herd app to ensure its local DNS is active, then visit `https://<folder-name>.test`.

## Introduction

Our Laravel + [Livewire](https://livewire.laravel.com) starter kit provides a robust, modern starting point for building Laravel applications with a Livewire frontend.

Livewire is a powerful way of building dynamic, reactive, frontend UIs using just PHP. It's a great fit for teams that primarily use Blade templates and are looking for a simpler alternative to JavaScript-driven SPA frameworks like React and Vue.

This Livewire starter kit utilizes Livewire 3, Laravel Volt (optionally), TypeScript, Tailwind, and the [Flux UI](https://fluxui.dev) component library.

If you are looking for the alternate configurations of this starter kit, they can be found in the following branches:

- [components](https://github.com/laravel/livewire-starter-kit/tree/components) - if Volt is not selected
- [workos](https://github.com/laravel/livewire-starter-kit/tree/workos) - if WorkOS is selected for authentication

## Official Documentation

Documentation for all Laravel starter kits can be found on the [Laravel website](https://laravel.com/docs/starter-kits).

## Contributing

Thank you for considering contributing to our starter kit! The contribution guide can be found in the [Laravel documentation](https://laravel.com/docs/contributions).

## Code of Conduct

In order to ensure that the Laravel community is welcoming to all, please review and abide by the [Code of Conduct](https://laravel.com/docs/contributions#code-of-conduct).

## License

The Laravel + Livewire starter kit is open-sourced software licensed under the MIT license.

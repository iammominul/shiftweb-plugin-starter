# ShiftWeb Plugin Starter

A reusable starting point for building custom WordPress plugins at ShiftWeb with
Claude Code. Copy it once per plugin, run the init step, and you get a clean,
namespaced, security-minded plugin with linting, tests, and a `CLAUDE.md` that
tells Claude Code how we work.

This is an internal tool. It is not meant for the WordPress.org directory.

---

## How to start a new plugin

You have three ways to spin up a new plugin from this starter. Pick whichever
fits how you work.

### Option 1: GitHub "Use this template" (recommended for the team)

1. On GitHub, click **Use this template > Create a new repository**.
2. Clone your new repo locally.
3. Run the init script (see Option 2) to fill in the names.

### Option 2: Run the init script

From the repo root:

**Windows (PowerShell):**

```powershell
./scripts/init-plugin.ps1 -Name "Booking Reminders" -Description "Sends booking reminder emails."
```

**macOS / Linux (bash):**

```bash
./scripts/init-plugin.sh "Booking Reminders"
```

The script derives everything from the name and replaces the placeholders below
across every file, then renames `plugin-name.php` to your slug. You can override
the slug, namespace, author, and URLs with parameters (see the top of each
script).

### Option 3: Let Claude Code do it

Open the folder in Claude Code and say:

> Initialize this plugin. Name: "Booking Reminders". Description: "Sends booking
> reminder emails to customers."

Claude Code will read `CLAUDE.md`, fill in the placeholders, rename the main
file, and remove this starter README. Answer its questions as they come up.

---

## Placeholders the init step fills in

| Token | Meaning | Example |
|---|---|---|
| `{{PLUGIN_NAME}}` | Display name in the plugins list | `Booking Reminders` |
| `{{PLUGIN_SLUG}}` | Folder, main file, and text domain | `booking-reminders` |
| `{{PLUGIN_NAMESPACE}}` | PHP namespace root | `ShiftWeb\BookingReminders` |
| `{{PLUGIN_PREFIX}}` | Function / option prefix (snake_case) | `booking_reminders` |
| `{{PLUGIN_CONSTANT}}` | Constant prefix (UPPER_CASE) | `BOOKING_REMINDERS` |
| `{{PLUGIN_DESCRIPTION}}` | One-line description | `Sends booking reminder emails.` |
| `{{PLUGIN_AUTHOR}}` | Author | `ShiftWeb` |
| `{{PLUGIN_AUTHOR_URI}}` | Author URL | `https://shiftweb.com` |
| `{{PLUGIN_URI}}` | Plugin homepage | `https://shiftweb.com` |

---

## First-time setup after init

```bash
composer install     # install dev tooling (PHPCS, PHPUnit)
composer lint        # check WordPress Coding Standards
composer lint:fix    # auto-fix what it can
composer test        # run PHPUnit
```

Then read `CLAUDE.md` and fill out `INTAKE.md` with the project brief before you
build anything.

---

## What is in the box

```
.
├── CLAUDE.md              # Rules for Claude Code on this plugin
├── INTAKE.md              # Project brief to fill out with the requester
├── plugin-name.php        # Plugin bootstrap (renamed on init)
├── uninstall.php          # Clean removal
├── readme.txt             # WordPress-style readme / changelog
├── composer.json          # Autoloading + dev tooling
├── phpcs.xml.dist         # WordPress Coding Standards ruleset
├── phpunit.xml.dist       # Test config
├── src/                   # Namespaced OO classes (PSR-4)
├── assets/                # CSS / JS (enqueued only where needed)
├── languages/             # Translation files
├── tests/                 # PHPUnit
├── scripts/               # init-plugin scripts
└── .github/workflows/     # CI: lint + tests
```

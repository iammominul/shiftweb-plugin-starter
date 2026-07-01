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
./scripts/init-plugin.ps1 -Name "Plugin Name" -Description "A short description of what the plugin does."
```

**macOS / Linux (bash):**

```bash
./scripts/init-plugin.sh "Plugin Name"
```

Replace "Plugin Name" with your plugin's real name. The script derives everything
from it and replaces the placeholders below across every file, then renames
`plugin-name.php` to your slug. You can override the slug, namespace, author, and
URLs with parameters (see the top of each script). As a convenience, a name that
starts with "ShiftWeb" is deduped, so "ShiftWeb Core" gives the namespace
`ShiftWeb\Core` rather than the redundant `ShiftWeb\ShiftwebCore`.

### Option 3: Let Claude Code do it

Open the folder in Claude Code and say:

> Initialize this plugin. Name: "Plugin Name". Description: "A short description of
> what the plugin does."

Claude Code will read `CLAUDE.md`, fill in the placeholders, rename the main
file, and remove this starter README. Answer its questions as they come up.

---

## Placeholders the init step fills in

| Token | Meaning | Example |
|---|---|---|
| `{{PLUGIN_NAME}}` | Display name in the plugins list | `Plugin Name` |
| `{{PLUGIN_SLUG}}` | Folder, main file, and text domain | `plugin-name` |
| `{{PLUGIN_NAMESPACE}}` | PHP namespace root | `ShiftWeb\PluginName` |
| `{{PLUGIN_PREFIX}}` | Function / option prefix (snake_case) | `plugin_name` |
| `{{PLUGIN_CONSTANT}}` | Constant prefix (UPPER_CASE) | `PLUGIN_NAME` |
| `{{PLUGIN_DESCRIPTION}}` | One-line description | `A custom WordPress plugin by ShiftWeb.` |
| `{{PLUGIN_AUTHOR}}` | Author | `ShiftWeb` |
| `{{PLUGIN_AUTHOR_URI}}` | Author URL | `https://shiftweb.com` |
| `{{PLUGIN_URI}}` | Plugin homepage | `https://shiftweb.com` |

Every value is derived from the name. A name that starts with "ShiftWeb" has that
word dropped before the namespace is built, so "ShiftWeb Core" becomes
`ShiftWeb\Core` rather than `ShiftWeb\ShiftwebCore`.

---

## First-time setup after init

```bash
composer install     # install dev tooling (PHPCS, PHPStan, PHPUnit)
composer lint        # check WordPress Coding Standards
composer lint:fix    # auto-fix what it can
composer analyze     # PHPStan static analysis
composer test        # run PHPUnit
composer check       # lint + analyze + test (run before every PR)
```

Then read `CLAUDE.md` and fill out `INTAKE.md` with the project brief before you
build anything.

---

## Packaging a release

When a plugin is ready to install on a site, build a clean zip:

**Windows (PowerShell):**

```powershell
./scripts/build-zip.ps1
```

**macOS / Linux (bash):**

```bash
./scripts/build-zip.sh
```

The script stages a copy, installs runtime-only dependencies with the optimized
autoloader, strips development files (tests, scripts, CI config, tooling config,
and this README), and writes `dist/<slug>-<version>.zip` with the slug as the
top-level folder. Upload it via Plugins > Add New > Upload Plugin. Run
`composer check` first so you never ship a failing build.

---

## What is in the box

```
.
├── CLAUDE.md              # Engineering rules for Claude Code on this plugin
├── INTAKE.md              # Project brief to fill out with the requester
├── plugin-name.php        # Plugin bootstrap (renamed on init)
├── uninstall.php          # Clean removal
├── readme.txt             # WordPress-style readme / changelog
├── composer.json          # Autoloading + dev tooling
├── phpcs.xml.dist         # WordPress Coding Standards ruleset
├── phpstan.neon.dist      # Static analysis config
├── phpunit.xml.dist       # Test config
├── src/                   # Namespaced OO classes (PSR-4)
├── assets/                # CSS / JS (enqueued only where needed)
├── languages/             # Translation files
├── tests/                 # PHPUnit
├── scripts/               # init-plugin and build-zip scripts
├── dist/                  # Built release zips land here (git-ignored)
└── .github/workflows/     # CI: lint + analyze + tests
```

## The rules (CLAUDE.md)

`CLAUDE.md` is the heart of this starter. It is a full engineering contract that
tells Claude Code how to write the code: clean architecture and strict types,
WordPress API best practices, a non-negotiable security model (validate,
sanitize, escape, nonces, capabilities, prepared statements), performance rules
(no N+1, cache expensive work, conditional asset loading), a testing policy
(test-first for security-critical logic), and a hard definition of done that
every change must pass. Read it before building, and keep it in every plugin you
generate from this starter.

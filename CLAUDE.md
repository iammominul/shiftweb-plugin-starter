# CLAUDE.md - {{PLUGIN_NAME}}

Project guidance for Claude Code. Read this before writing any code. ShiftWeb
builds and maintains 200+ live client WordPress sites, so a custom plugin that
misbehaves can affect real businesses. Treat correctness, security, and polish
as release criteria, not extras.

---

## What this plugin is

{{PLUGIN_DESCRIPTION}}

Fill in the full brief in `INTAKE.md` before building. If the brief is missing
details you need (who uses it, where it runs, what data it touches), ask the
requester. Do not guess your way past an unclear requirement.

---

## Collaboration rules (important)

The requester wants to be involved. Ask questions early and often instead of
guessing. Specifically, surface a question whenever:

- The requirement is ambiguous or could be read two ways.
- You are about to make a decision that is hard to reverse (data model, public
  URLs, option names, external services).
- You need something only the requester has (API keys, brand assets, copy, the
  target site list, where files should live).
- A request conflicts with a security or quality rule in this file.

When you ask, give a short recommendation and your reasoning, not just an open
question. Small, reviewable pull requests, one feature each.

---

## Tech stack and conventions

| Concern | Choice |
|---|---|
| Language | PHP 7.4 minimum, target PHP 8.1+ |
| WordPress | 6.0+ |
| Structure | Object-oriented, namespaced `{{PLUGIN_NAMESPACE}}`, PSR-4 autoloading |
| Dependencies | Composer-managed. Ask before adding any new runtime dependency. |
| Testing | PHPUnit for non-trivial logic |
| Code quality | PHPCS with WordPress Coding Standards, enforced in CI |
| i18n | All user-facing strings wrapped in translation functions from day one |

### Layout

```
{{PLUGIN_SLUG}}/
├── {{PLUGIN_SLUG}}.php     # bootstrap: header, guard, autoload, run()
├── uninstall.php           # clean removal of options and tables
├── src/                    # {{PLUGIN_NAMESPACE}} namespaced classes
├── assets/                 # css / js / images
├── languages/              # .pot and translations
└── tests/                  # PHPUnit
```

### Naming

- Text domain and main file name equal the slug: `{{PLUGIN_SLUG}}`.
- Option keys, transients, cron hooks, and global functions are prefixed
  `{{PLUGIN_PREFIX}}_`.
- Constants are prefixed `{{PLUGIN_CONSTANT}}_`.
- Classes are namespaced under `{{PLUGIN_NAMESPACE}}`. No global classes.

---

## Security (non-negotiable)

Every one of these applies to all code you write.

- Sanitize all input with the appropriate WordPress functions
  (`sanitize_text_field`, `absint`, `sanitize_email`, and so on).
- Escape all output at the point of output: `esc_html()`, `esc_attr()`,
  `esc_url()`, `wp_kses_post()`.
- Every custom database query uses `$wpdb->prepare()`. No exceptions.
- Nonces AND capability checks on every form, AJAX endpoint, and privileged
  action. Check the right capability for the action (`manage_options` for
  settings, not just `is_admin()`).
- Never trust `$_GET`, `$_POST`, `$_REQUEST`, or `$_SERVER` without validating
  and unslashing (`wp_unslash`) first.
- No `eval()`. No `base64_decode()` on user input. No dynamic file includes
  built from user input.
- Never commit secrets, API keys, or `.env` files. Store secrets in options set
  by an admin, never hardcoded. Never log a secret.
- Load assets only where they are needed. Gate enqueues on the current screen or
  page slug, and version-bust with the plugin version constant.

Must pass PHPCS (WordPress Coding Standards) before any change is "done".

---

## Writing style (ShiftWeb house rule)

Do not use em dashes or en dashes ( -- or the long dash ) in any user-facing
copy: plugin headers, admin notices, settings labels, help text, readme, or
commit messages. They read as AI-generated and hurt the agency's reputation.
Use plain hyphens, commas, colons, parentheses, or separate sentences instead.
This applies to code comments that ship in user-visible strings too.

---

## Accessibility and UI

- Target WCAG 2.1 AA. Visible keyboard focus on every interactive element.
- Do not signal status with color alone. Pair color with an icon and a label.
- Design empty and error states, not just the happy path.
- Follow the ShiftWeb brand tokens where the plugin has a branded surface. Never
  hardcode brand hex values if a token is available.

---

## Workflow rules for Claude Code

- One feature per pull request. Keep diffs small and reviewable.
- For security-critical logic (auth, token handling, anything touching secrets),
  write the PHPUnit tests first, then implement.
- Run PHPCS and the test suite before declaring anything finished.
- Ask before adding any new Composer runtime dependency. Performance on client
  sites matters.
- Prefer cached data (options, transients, cron-refreshed) over live queries on
  front-facing or dashboard pages.
- Never weaken a security rule above to make something work. Flag the tension to
  the requester instead.

---

## Commands

```bash
composer install     # install dependencies
composer test        # run PHPUnit
composer lint        # PHPCS against WordPress Coding Standards
composer lint:fix    # auto-fix fixable PHPCS issues
```

# CLAUDE.md - {{PLUGIN_NAME}}

This file is the engineering contract for this plugin. Read it before writing any
code, and follow it on every change. It tells Claude Code how we build WordPress
plugins: clean, secure, tested, fast, and readable by the next developer.

Rules written as "Always" or "Never" are non-negotiable. If a task seems to
require breaking one, stop and raise it with the requester instead of quietly
working around it.

---

## What this plugin is

{{PLUGIN_DESCRIPTION}}

Fill in the full brief in `INTAKE.md` before building. If the brief is missing
something you need (who uses it, where it runs, what data it touches, which
sites), ask. Do not guess past an unclear requirement.

---

## 1. The quality bar

"It works" is not the finish line. Every change must be:

- **Correct**, including edge cases and failure paths, not just the happy path.
- **Secure** by default (see section 5).
- **Tested** where the logic is non-trivial or security-critical (see section 9).
- **Fast** on a real site with real data volume (see section 6).
- **Clean**: readable, small, and consistent with the surrounding code.

A change is only "done" when it passes the checklist in section 11.

---

## 2. How to work

- **Understand before coding.** Restate the goal in your own words. Confirm
  anything ambiguous before writing code.
- **Ask questions early** when: the requirement is ambiguous, a decision is hard
  to reverse (data model, public URLs, option keys, external services), you need
  something only the requester has (keys, copy, brand assets, the site list), or
  a request conflicts with a rule in this file. Give a recommendation with your
  question, not just an open-ended one.
- **Small, single-purpose pull requests.** One feature or fix each.
- **Match the codebase.** Reuse existing patterns, naming, and structure before
  inventing new ones.
- **Leave it clean.** No dead code, no commented-out blocks, no leftover debug
  output, no stray TODOs.
- **Ask before adding any runtime (non-dev) dependency.** Keep the plugin light.

---

## 3. Clean code and architecture

- **`declare(strict_types=1);`** at the top of every PHP file.
- **Type everything**: parameter types, return types, and typed properties.
  Prefer precise types and nullable types over `mixed`.
- **Single Responsibility.** One class, one job. One function, one job. Keep
  functions short and at a single level of abstraction. If a function needs a
  comment to explain a block, extract that block into a well-named method.
- **Namespaced, PSR-4, object-oriented.** No business logic in the main plugin
  file beyond bootstrapping. No global functions except thin, prefixed helpers.
- **Meaningful names.** No cryptic abbreviations. Booleans read as predicates
  (`is_active`, `has_access`). Names reveal intent so comments are rarely needed.
- **Guard clauses over nesting.** Return early; keep the happy path un-indented.
- **No magic values.** Replace literal numbers and repeated strings with named
  constants or config.
- **Separate concerns.** Keep HTML out of logic classes (use templates or
  dedicated view methods). Keep data access in dedicated service or repository
  classes, not scattered through the codebase.
- **Avoid hidden global state.** Prefer passing dependencies in (constructor
  injection) over reaching for globals or static singletons. The one acceptable
  singleton is the root plugin container.
- **DRY, but not at the cost of clarity.** Do not over-abstract for a single use.
- **Fail loudly in development.** Never silence errors with `@`. Use exceptions
  for truly exceptional states and handle them at a sensible boundary.

---

## 4. WordPress best practices

- **Use the WordPress API instead of raw PHP when one exists.** HTTP through
  `wp_remote_get()` / `wp_remote_post()` (never raw cURL), filesystem through
  `WP_Filesystem`, redirects through `wp_safe_redirect()`, email through
  `wp_mail()`, dates through `wp_date()` / `current_time()`, scheduling through
  WP-Cron.
- **Prefer core query APIs** (`WP_Query`, `get_posts`, `get_option`) over raw
  `$wpdb`. If a custom query is unavoidable, it goes through `$wpdb->prepare()`
  every time, and custom tables are created with `dbDelta()`.
- **Store data in the right place.** Site config in options, post data in post
  meta, user data in user meta. Create a custom table only when the data model
  genuinely needs it, and justify it.
- **Hooks are the integration surface.** Register hooks in one place, keep
  callbacks thin and delegating, use the correct hook and priority, and unhook or
  unschedule anything you set up (cron, transients) on deactivation.
- **Enqueue assets properly.** Always `wp_enqueue_script()` / `wp_enqueue_style()`
  with declared dependencies and the plugin version for cache-busting. Never hand-
  write `<script>` or `<link>` tags. Enqueue only on the screens that need them.
- **Settings API for admin settings.** Do not hand-roll option saving; let core
  handle the nonce, storage, and rendering flow.
- **Capabilities, not roles.** Gate actions with `current_user_can( 'some_cap' )`,
  never by comparing role names.
- **Prefix everything global**: functions, hooks, option keys, transients, and
  cron events with `{{PLUGIN_PREFIX}}_`; classes live under `{{PLUGIN_NAMESPACE}}`.
- **Never modify core and never hack around other plugins.** Integrate through
  documented hooks and filters.
- **Clean up on uninstall.** Remove your own options and tables in `uninstall.php`.
  Do not delete content the site still needs.
- **Be multisite-aware** wherever the plugin could run on a network.

---

## 5. Security (non-negotiable)

Know the three distinct jobs and do all three:

- **Validate** input: is it the shape and range we expect? Reject if not.
- **Sanitize** on the way in / before storage, with the matching function.
- **Escape** on the way out, as late as possible, at the point of echo.

Rules:

- **Sanitize every input** from `$_GET`, `$_POST`, `$_REQUEST`, `$_SERVER`,
  cookies, and REST/AJAX payloads, after `wp_unslash()`, with the right function
  (`sanitize_text_field`, `absint`, `sanitize_email`, `esc_url_raw`, and so on).
- **Escape every output**: `esc_html()`, `esc_attr()`, `esc_url()`,
  `esc_textarea()`, `wp_kses_post()`. Never echo a raw variable.
- **Nonces AND capability checks** on every form, AJAX handler, REST route, and
  privileged action. A nonce proves intent, not permission, so always check the
  capability too. REST routes always set a real `permission_callback` (never
  `__return_true` for anything privileged).
- **Prepared statements** for all custom SQL. Never interpolate a variable into a
  query string.
- **Never trust the client.** Re-validate and re-authorize on the server.
- **Forbidden**: `eval()`, `create_function()`, `base64_decode()` on user input,
  `unserialize()` of untrusted data, and dynamic file includes built from input.
- **Secrets** (API keys, tokens, passwords): never hardcode, never commit, never
  log, never render back to the browser. Store in options set by an admin, and
  encrypt at rest if they are sensitive.
- **File uploads** go through `wp_handle_upload()` with type and size validation
  via `wp_check_filetype_and_ext()`.
- **Redirects** to any dynamic target use `wp_safe_redirect()`.

Treat "would this diff pass a security review?" as a gate on every change.

---

## 6. Performance (this runs on real sites)

- **No queries inside loops.** Avoid N+1: batch lookups, prime caches, or shape a
  single `WP_Query` correctly.
- **Cache expensive work.** Use transients for remote or costly data and the
  object cache (`wp_cache_*`) for repeated per-request reads. Set sensible
  expirations and invalidate on write.
- **Never do live external calls on a front-end or dashboard render.** Refresh via
  WP-Cron and read cached data on the page.
- **Keep autoloaded options small.** Set `autoload = 'no'` for large or rarely
  read options.
- **Load only what is needed.** Conditionally enqueue assets by screen, lazy-init
  heavy objects, and gate admin-only code behind `is_admin()`. Do not do real
  work on every request in `plugins_loaded`.
- **Query lean.** Use `'fields' => 'ids'` when you only need IDs, set
  `'no_found_rows' => true` when you do not paginate, and always bound
  `posts_per_page`. Never run an unbounded query.
- **Defer non-critical work** to cron or async requests instead of blocking the
  page.
- **Measure, do not guess.** Use Query Monitor to find real hotspots. Avoid
  premature micro-optimization, but never ship an obvious N+1 or O(n^2).

---

## 7. Database discipline (do not bloat the site)

The plugin shares one database with the whole site, and on ShiftWeb sites those
tables are already large. Treat schema and row growth as a cost you own.

- **Store data in the right place.** Site config in options, per-entity data in
  post or user meta, large or queryable datasets in a purpose-built custom table.
  Do not push everything into `wp_options`.
- **Guard the autoload cache.** Autoloaded options load on every single request.
  Keep them small and set `autoload = 'no'` for anything large or rarely read.
  Never grow one option unboundedly (no logs, event streams, or ever-expanding
  arrays in a single row).
- **Do not accumulate.** Anything you create, you clean up: expire transients,
  delete rows you no longer need, and schedule a cron job to prune log, cache, or
  time-series data so a table cannot grow without limit.
- **Custom tables, only when justified**: create and migrate with `dbDelta()`,
  version the schema, add an index on every column you filter, join, or sort by,
  choose the narrowest correct column types, and drop the table in
  `uninstall.php`.
- **Meta scales poorly for querying.** Do not build features around large
  `meta_query` lookups. If you must query data at scale, model it in a custom
  table with real indexes. Never store a serialized blob you later need to search.
- **Write sparingly on the front end.** Do not INSERT or UPDATE synchronously on
  every page view (for example a hit counter). Batch it, defer to cron, or buffer
  in the object cache and flush periodically.
- **Remove orphans.** When a parent entity is deleted, delete its related meta and
  rows too (hook `before_delete_post`, `deleted_user`, and so on).
- **Every custom query uses `$wpdb->prepare()`** (see section 5) and reads through
  a cache where it is hot.

---

## 8. Internationalization and accessibility

- **Every user-facing string** is wrapped in a translation function
  (`__()`, `esc_html__()`, `esc_attr_e()`, and so on) with the `{{TEXT_DOMAIN}}`
  text domain. Use `printf()` placeholders, never string concatenation, and add
  translator comments for placeholders.
- Ship a `.pot` template; keep translations under `/languages`.
- **Admin UI targets WCAG 2.1 AA.** Keyboard operable, visible focus on every
  interactive element, labels tied to inputs, sufficient contrast, and never
  status by color alone (pair color with an icon and text).

---

## 9. Testing

- **PHPUnit for logic.** Write the test first for anything security-critical
  (auth, token handling, sanitization, capability gating) and for every bug fix
  (a failing test that reproduces the bug, then the fix).
- **Structure**: Arrange, Act, Assert. One behavior per test. Descriptive test
  method names that state the expectation.
- **Keep unit tests fast and isolated**: no network, no real database. Mock
  WordPress functions with Brain Monkey or WP_Mock, or use the WordPress
  integration test suite when you genuinely need hook or DB behavior.
- **Cover edge cases and failure paths**, not just the happy path.
- **Test your logic, not WordPress or the framework.** Coverage is a signal, not
  a target; aim for meaningful coverage of the business logic.

---

## 10. Documentation and error handling

- **DocBlocks** on classes and public methods: purpose, `@param`, `@return`,
  `@throws`. Explain the "why", not the obvious "what".
- **Handle failures gracefully.** Wrap fallible operations (HTTP, filesystem,
  JSON) in try/catch, and check `is_wp_error()` on WordPress API returns. Degrade
  gracefully and show a friendly admin notice; never surface a raw error or stack
  trace to a user.
- **Log behind `WP_DEBUG`**, never in production output, and never log secrets.
- **Never** leave `var_dump()`, `print_r()`, `error_log()` debugging, or
  `console.log()` in shipped code.

---

## 11. Definition of done

A change is done only when all of these are true:

- It meets the requirement and its edge cases.
- `composer lint` (PHPCS), `composer analyze` (PHPStan), and `composer test`
  (PHPUnit) all pass with no new warnings.
- New or changed logic has tests.
- All input is sanitized, all output escaped, and every privileged path has a
  nonce and capability check.
- All user-facing strings are translatable.
- No debug output, no dead code, no commented-out blocks.
- DocBlocks are updated, and `readme.txt` / changelog is bumped if the change is
  user-facing.

---

## 12. Writing style (house rule)

Do not use em dashes or en dashes in any user-facing copy: plugin headers, admin
notices, settings labels, help text, `readme.txt`, or commit messages. They read
as AI-generated. Use plain hyphens, commas, colons, parentheses, or separate
sentences instead.

---

## 13. Commands

```bash
composer install     # install dependencies
composer lint        # PHPCS against WordPress Coding Standards
composer lint:fix    # auto-fix fixable PHPCS issues
composer analyze     # PHPStan static analysis
composer test        # PHPUnit
composer check       # lint + analyze + test (run before every PR)
```

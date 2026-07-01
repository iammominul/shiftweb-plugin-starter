# Plugin Intake Brief

Fill this out with the requester before writing code. It is fine to start with
partial answers and fill gaps as questions come up. The goal is a shared
understanding, not a perfect document.

Plugin name:
Date:
Requested by:
Developer(s):

---

## 1. Purpose

- What is the one job this plugin does?
- What problem does it solve, and for whom?
- Who uses it: site admins, editors/authors, or front-end visitors/customers?
- What does "done" look like? How will we know it works?

## 2. Where it runs

- Which site(s) does it run on? One site, several, or multisite?
- Production only, or staging first?
- How is it deployed and updated: MainWP, manual upload, or git?

## 3. Behavior

- Where does it appear? (admin settings page, a block or shortcode, a widget,
  the front end, a background/scheduled task)
- Does it store data? If so, WordPress options and post meta, or a custom table?
- Does it send email or notifications?
- Does it run anything on a schedule (cron)?
- Does it call any third-party service or API? Which ones, and who supplies the
  keys?
- Does it depend on any other plugin being active?

## 4. Guardrails and constraints

- Minimum WordPress version we must support:
- Minimum PHP version we must support:
- Author and license (default: ShiftWeb, GPL v2 or later):
- Any sensitive data involved (credentials, customer data, PII)?
- Any performance limits to respect (large catalogs, high traffic)?
- Does it need translations / multiple languages?

## 5. Look and feel

- Does it have a branded surface, or is it purely functional/behind the scenes?
- Any specific copy, labels, or brand assets the requester wants to provide?

## 6. Delivery

- Where does the code live? (repo name / location)
- Who reviews it before it goes live?
- How do we test it before rollout? Any pilot sites?
- Versioning and changelog expectations?

---

## Open questions

Track anything still unresolved here so it does not get lost.

-

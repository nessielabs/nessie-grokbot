# Changelog

Notable changes to the Nessie skill and Grok Bot / Cursor plugin are documented
here. From 0.1.3 onward, numbered entries track `skill-version.json`; the plugin
manifest has a separate version, labeled explicitly below. Earlier entries use
the plugin version because the skill did not yet have its own version pointer.

History is backfilled from merged pull requests and their final version files.
Dates are UTC merge dates; the pending 0.1.13 entry uses its sync commit date.
Intermediate skill versions 0.1.4 and 0.1.7 never reached `main` separately;
their changes are included in 0.1.5 and 0.1.8. Entries record repository changes,
not independently verified marketplace publication dates.

## 0.1.14 - 2026-09-18

- Skill: update the bundled Nessie guidance.

## 0.1.13 - 2026-09-17

- Skill: document imported-email search with `type: "email"`, sender/recipient/subject filters, message and thread reads, and `pageToken` pagination in `nessie_grep`.
- Skill: clarify that `nessie_integration_list` discovers personal and incoming shared integration roots, excluding native folders, contexts, and skills.
- Skill: distinguish cloud literal-search behavior from local contiguous-substring matching.

## 0.1.12 - 2026-09-15

- Skill: document recursive `nessie_ls` discovery, Contexts-root sorting, and date filters on each listed row's own updated time.
- Skill: browse ChatGPT Projects as read-only chat directories with Viewer-only grants; list containers without transcript-only filters to discover their subdirectories. ([#12](https://github.com/nessielabs/nessie-grokbot/pull/12))

## 0.1.11 - 2026-09-09

- Skill: browse and search imported Mac and Windows files, read extracted text, and preserve source references in contexts; explain when hosted access requires Cloud Sync. ([#11](https://github.com/nessielabs/nessie-grokbot/pull/11))

## 0.1.10 - 2026-09-03

- Skill: generate the bundled instructions from the shared canonical sources, preserve Grok Bot / Cursor setup and update guidance, and record the upstream commit for future automatic syncs. ([#10](https://github.com/nessielabs/nessie-grokbot/pull/10))

## 0.1.9 - 2026-09-03

- Skill: document skill usage analytics with `nessie_skill_analytics_overview` and `nessie_skill_analytics`, plus hourly token analytics; update connection-verification guidance. ([#9](https://github.com/nessielabs/nessie-grokbot/pull/9))

## 0.1.8 - 2026-09-01

- Skill: discover native Claude Code and Codex memory with the `memory` filter, treat it as read-only project orientation requiring verification, and fall back to provider-specific filters on older hosts. Includes the intermediate 0.1.7 changes. ([#8](https://github.com/nessielabs/nessie-grokbot/pull/8))

## 0.1.6 - 2026-08-30

- Skill: filter session listing, search, stat, and resume workflows by human, agent, or automation initiation while preserving raw execution metadata and traversal constraints. ([#7](https://github.com/nessielabs/nessie-grokbot/pull/7))

## Plugin 0.1.3 - 2026-08-27

- Setup: identify Grok Bot / Cursor traffic with `?client=grokbot` on the hosted MCP URL while preserving native OAuth. The skill remains at 0.1.5. ([#6](https://github.com/nessielabs/nessie-grokbot/pull/6))

## 0.1.5 - 2026-08-25

- Skill: use the provider-neutral `meeting` category for discovery and search across meeting providers, retaining provider-specific filters for explicit requests. Includes the intermediate 0.1.4 changes. ([#5](https://github.com/nessielabs/nessie-grokbot/pull/5))

## 0.1.3 - 2026-08-24

- Skill: check the published version on first use and offer an update with user consent; add the remote version pointer and manual reinstall guidance for existing copies. ([#4](https://github.com/nessielabs/nessie-grokbot/pull/4))

## 0.1.2 - 2026-08-20

- Skill: find named folders and contexts with server-side name filters, following pagination until discovery is complete. ([#3](https://github.com/nessielabs/nessie-grokbot/pull/3))

## 0.1.1 - 2026-08-18

- Skill: answer token and request usage questions with `nessie_analytics`; add analytics examples and connection checks. ([#2](https://github.com/nessielabs/nessie-grokbot/pull/2))

## 0.1.0 - 2026-08-15

- Plugin: introduce the public Grok Bot / Cursor package, bundled Nessie skill, official logo, and URL-only hosted MCP configuration with native OAuth. ([#1](https://github.com/nessielabs/nessie-grokbot/pull/1))

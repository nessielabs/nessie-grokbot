# Contributing

This public repository is the single home for the Grok Bot and Cursor plugin
packaging. The agent behavior in `skills/nessie/SKILL.md` is generated from
the canonical sources in the private `nessielabs/nessie-codebase` repository
(`packages/nessie-agent-instructions`: the shared core, the MCP adapter, and
this host's preamble). A workflow there opens a `skill-sync/canonical` pull
request here whenever those sources change; `skill-source.json` records the
exact upstream commit the current skill was generated from.

## Update the skill

1. Do not hand-edit `skills/nessie/SKILL.md`. The next sync would overwrite
   the change. Edit the canonical sources in `nessie-codebase` instead; the
   Grok Bot and Cursor-specific setup, authentication, and update guidance
   live in that repository's Grok Bot preamble.
2. Review the generated `skill-sync/canonical` pull request, run this
   repository's validation, and merge it with a merge commit.
3. The sync injects the `version:` frontmatter from `skill-version.json` and
   bumps the patch version; the pre-commit hook enforces the same lockstep
   for any local commit that touches `skills/`.

## Skill versioning

Installed copies of the skill detect updates by comparing their `version`
frontmatter against `skill-version.json` in this repository. Keep the
frontmatter, the "Skill Updates" section, and `skill-version.json` in the same
commit whenever shipped skill behavior changes.

The two must never diverge: the frontmatter is what installed copies hold
locally, and `skill-version.json` is the remote pointer they poll.

The bump is automated by a pre-commit hook. Install it once after cloning:

```bash
git config core.hooksPath scripts/hooks
```

When a commit stages changes under `skills/`, the hook bumps the patch version
in both files and stages them. To set a version by hand (e.g. a minor bump),
stage your edited `skill-version.json` in the same commit; the hook then
leaves both files alone, so set the frontmatter yourself to match.

`scripts/validate.sh` enforces this lockstep (and the presence of the "Skill
Updates" section) and runs in CI on every push and pull request.

## Secrets

Never commit a real Nessie API key. The published Cursor configuration stays
URL-only so Cursor can initiate OAuth. Keys start with `sk_nes_v1_` and belong
only in a non-OAuth client's private MCP configuration.

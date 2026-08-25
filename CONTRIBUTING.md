# Contributing

This public repository is the single home for the Grok Bot and Cursor plugin
packaging. The agent behavior in `skills/nessie/SKILL.md` is maintained
directly in this repository through normal pull requests. The private
`nessielabs/nessie-codebase` repository does not export or update this file.

## Update the skill

1. Edit `skills/nessie/SKILL.md` directly in a branch in this repository.
2. Preserve the Grok Bot and Cursor-specific setup, authentication, and update
   guidance while keeping shared Nessie behavior consistent with the other
   public skill repositories.
3. Review `git diff -- skills/nessie/SKILL.md` and run the validation steps in
   this repository's pull request.
4. Commit the skill together with any matching plugin documentation. The
   pre-commit hook applies the required patch-version update automatically.

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

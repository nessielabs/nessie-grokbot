# Contributing

This public repository is the single home for the Grok Bot and Cursor plugin
packaging. The agent behavior in `skills/nessie/SKILL.md` is generated from the
private `nessielabs/nessie-codebase` monorepo.

Refreshing the public skill is a manual release step. Monorepo CI validates its
in-repo generated artifacts, but it cannot update or verify this separate public
repository automatically.

## Refresh the generated skill

1. Check out the monorepo change that updates
   `packages/nessie-agent-instructions`.
2. From this repository's root, export the Cursor target:

   ```bash
   node /absolute/path/to/nessie-codebase/packages/nessie-agent-instructions/scripts/build.mjs \
     --target cursor \
     --out-dir "$PWD"
   ```

3. Review `git diff -- skills/nessie/SKILL.md` and run the validation steps in
   this repository's pull request.
4. Commit the generated skill together with any matching plugin documentation
   or version update.

Do not edit `skills/nessie/SKILL.md` directly. A future refresh must always be
exported again from the monorepo source. Use the documented space-separated
options; the exporter does not accept `--target=cursor` or `--out-dir=...`.

## Skill versioning

Installed copies of the skill detect updates by comparing their `version`
frontmatter against `skill-version.json` in this repository. On every skill
refresh, bump the `version` field in the monorepo's
`packages/nessie-agent-instructions/src/preambles/cursor.md` frontmatter and
update `skill-version.json` here to the same value in the same commit. The two
must never diverge: the frontmatter is what installed copies hold locally, and
`skill-version.json` is the remote pointer they poll.

## Secrets

Never commit a real Nessie API key. The published Cursor configuration stays
URL-only so Cursor can initiate OAuth. Keys start with `sk_nes_v1_` and belong
only in a non-OAuth client's private MCP configuration.

# Nessie for Grok Bot and Cursor

Bring your Nessie context library into Grok Bot and Cursor. This plugin connects
to Nessie's hosted MCP server and teaches the agent how to search, read, and
safely write context using Nessie's MCP tools.

## Requirements

- A Nessie account
- **Cloud Sync enabled** in Nessie
- Grok Bot or Cursor with plugin support

The hosted MCP reads the cloud copy of your Nessie library. If Cloud Sync is
off, local-only contexts and conversations are unavailable to Grok Bot or
Cursor.

## Install

After the plugin is published, open **Settings → Plugins**, find **Nessie**, and
select **Install**. In versions that label this area **Customize**, open
Customize and install Nessie there.

For local development, copy this repository into Cursor's local plugin
directory, then restart Cursor or run **Developer: Reload Window**:

```bash
cd /path/to/nessie-grokbot
mkdir -p ~/.cursor/plugins/local/nessie
cp -R .cursor-plugin assets skills README.md mcp.json LICENSE \
  ~/.cursor/plugins/local/nessie/
```

## Authenticate

Cursor supports OAuth for remote HTTP MCP servers. When Nessie shows **Needs
authentication** or a **Connect** button, select it and authorize Nessie. The
plugin intentionally leaves the `Authorization` header unset so Cursor can run
its native OAuth flow.

If another MCP client only supports static headers, use a Nessie API key as a
manual fallback:

1. In Nessie, open **Settings → API keys** and create a key. Nessie keys start
   with `sk_nes_v1_`.
2. In that client's MCP settings, add an `Authorization` header whose value is
   `Bearer ` followed by the Nessie API key.

Never paste a real API key into chat, source code, `mcp.json`, or a commit.

## Use Nessie

Start with:

> Nessie check-in

Then ask naturally, for example:

- "What did I decide about this project?"
- "Search my past conversations for this error."
- "What has my team already tried?"
- "Read the latest work Ethan shared with me."
- "Draft a brief using what I know in Nessie."

The bundled skill tells the agent to browse and search first, read full sources
before answering, and treat Nessie as read-only by default. Before any create,
edit, move, rename, or delete, the agent must show an exact preview and wait for
your confirmation.

The skill is generated upstream from Nessie's shared agent instructions. Do not
edit `skills/nessie/SKILL.md` directly; maintainers should follow
[CONTRIBUTING.md](CONTRIBUTING.md) to refresh it.

## Grok Bot

Grok Bot runs on a cloud computer, so it must use the public hosted MCP endpoint
configured by this plugin. It cannot reach the Nessie desktop app's local socket
or a local CLI session.

If Grok Bot stops at a team-configuration or entitlement screen before showing
plugins, a team admin must resolve that upstream gate first. Once the Nessie
plugin is available, connect with OAuth. Then run **Nessie check-in** to verify
`nessie_check_in`, `nessie_ls`, `nessie_grep`, and `nessie_cat` are available.

This plugin gives Grok Bot access to context already synchronized to Nessie
Cloud. It does not ingest Grok Bot's own cloud-hosted conversations into Nessie;
that requires a separate Grok Bot conversation-source integration.

## Troubleshooting

### Authentication or entitlement error

Reconnect the Nessie connector and complete Cursor's OAuth flow. For an MCP
client without OAuth, configure a Nessie API key as a static Bearer header in
that client's MCP settings. Do not share the key in chat.

### Empty or incomplete results

Confirm **Cloud Sync** is enabled in Nessie and has completed at least one sync.
The Nessie tools may also return a `cloud sync` notice; follow the action in that
notice before treating sparse results as an empty library.

### MCP connection errors

Open the Output panel and select **MCP Logs**. Confirm the configured URL is
`https://mcp.nessielabs.com/mcp`. In Cursor, use **Connect** or **Needs
authentication** to restart OAuth.

## Security and privacy

- The plugin connects only to `https://mcp.nessielabs.com/mcp`.
- Cursor manages OAuth credentials outside this repository.
- API-key fallback values for non-OAuth clients are not stored in this repo.
- Nessie access follows the authenticated user's permissions, including direct
  and team shares.
- Persistent writes require a preview and explicit confirmation.

## License

MIT

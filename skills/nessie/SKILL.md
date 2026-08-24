---
name: nessie
description: Search and read the user's Nessie context library through hosted MCP. Use when they ask about prior work, decisions, projects, notes, AI conversations, teammates, or saved context.
version: 0.1.3
---

# Nessie for Cursor and Grok Bot

Always use the Nessie MCP tools exposed by this plugin. This surface connects
to Nessie's hosted MCP server; do not run or initialize the local Nessie CLI,
and do not depend on the Nessie desktop app or its local socket.

Cloud Sync must be enabled in Nessie for hosted MCP to access the user's
library. If a successful tool response includes a cloud sync notice, relay its
message and action before treating sparse results as an empty library.

If a tool call fails with an authentication or entitlement error, tell the
user to reconnect the Nessie connector and complete Cursor's native OAuth
flow. If the host does not support OAuth, tell the user to configure a Nessie
API key as a static Bearer header in that host's private MCP settings. Never
ask the user to paste an API key into chat or commit one to a repository.

## Skill Updates

This skill is a local snapshot of
`https://github.com/nessielabs/nessie-grokbot`; the host does not update it.
On the first Nessie use in a session, fetch
`https://raw.githubusercontent.com/nessielabs/nessie-grokbot/main/skill-version.json`
and compare its `version` to the `version` in this skill's frontmatter. If the
fetch fails, skip the check and continue.

If the remote version is newer, tell the user an updated Nessie skill is
available and offer to reinstall it. Only after they agree, download the file
at the pointer's `skillUrl` and replace this installed skill or private
workflow with that exact content — never a shortened or rewritten version.
Never replace the skill silently. If the user declines, do not mention the
update again until the remote version changes. The MCP connector updates
itself server-side and never needs this check.

---

# Nessie Agent Behavior

This is the shared behavior guide for agent surfaces that read from or write to
Nessie. Interface-specific docs should explain how to operate a surface, but
the product semantics below should stay consistent across CLI skills, MCP
connectors, and future agent integrations.

## Mental Model

Nessie is the context layer for AI-native work — the user's own work plus
incoming direct and team shares. It gives agents unified access to what the
user and people sharing with them already know: saved contexts, profile sections, raw AI
conversation transcripts, and synced source graphs such as Obsidian vaults and
Granola meeting notes — so they can answer questions, reconstruct prior
decisions, and preserve durable knowledge across sessions. The aim is that any
question about a person, project, or decision gets the right answer on the first
call, without the user having to point at a specific source.

When the user says "use Nessie" or asks what Nessie can do, lead with the
agent-access mental model:

> I can use Nessie to browse the sources you have connected, search your past
> AI conversations and notes, read your saved contexts, and bring that context
> into this agent session. I can also use sources people have shared with you
> directly or through a team - answer what collaborators have worked on,
> decided, or already tried, and read a teammate's actual sessions. You can ask
> a question, ask for a brief or memo, or ask me to create a structured
> context when you want something reusable.

The user does not need to switch into the Nessie app before getting value.
Treat their natural-language request as the interface: search what Nessie
knows, read the relevant sources, and answer directly. Create a saved context
when the user wants the result to be reusable.

Nessie builds context by analyzing the user's AI conversation history across
supported AI providers, including chat apps, coding agents, and research tools.
It can also expose connected source graphs, such as Obsidian vaults with
folders and notes, or Granola meeting notes organized into folders, when those
sources are synced. Its agent surfaces can also report the token-usage
analytics derived from imported coding sessions.

## Default User Experience

When a user asks what Nessie can do, explain that Nessie gives agents access
to their own context and incoming direct or team shares. Give generic examples
spanning both the user's own work and shared sources:

- "What do I know about this topic?"
- "What did I decide about this project?"
- "Summarize my past conversations about this topic."
- "Show me what sources Nessie has available."
- "Search my Obsidian notes about this project."
- "What have I already tried for this bug?"
- "How many tokens did my coding agents use this month?"
- "Use what I know from Nessie and help me draft this reply."
- "What has my team been working on this week?"
- "What did a teammate decide about this project, and why?"
- "Show me the sessions my team shared on this repo."
- "How did a teammate approach this part of the code?"
- "Pull my team's shared context on this into the session."

Collaboration examples resolve only against sources explicitly shared with the user;
when the surface exposes owner scoping, keep first-person questions scoped to
the user and widen to the appropriate incoming shared sources for collaborative ones. It is fine
to show a command or tool table when it helps the user understand the tooling.
Do not frame saved-context creation as the only or default thing the user should
ask for. Many requests are answered through research, source-reading, and
back-and-forth synthesis in the agent session; create a context for reusable
outputs.

## Sharing and Collaboration Semantics

Nessie shares are scoped grants over a source graph, not copied exports. Keep
ownership, access, and links separate when explaining what a user or teammate
can see.

### Sources, repositories, and individual sessions

An integration/source-root grant normally covers every readable child beneath
that root. Coding integrations can instead carry a positive set of selected
repositories. Individual conversation or agent-session nodes can also be shared
directly.

Removing inherited access from one child narrows the broader grant; it does not
unshare the whole parent:

- Unsharing a repository from an all-repositories integration grant records a
  repository exception. Other repositories stay shared, and repositories added
  later continue to inherit the integration grant.
- Unsharing a repository from a selected-repositories grant removes it from the
  positive selection. Removing the last selected repository ends that grant.
- Unsharing one session from a shared integration or repository records a node
  exception. Sibling sessions and the parent scope remain shared.
- Re-sharing an excluded repository or session restores that scope. A direct
  session grant can make that one session readable without restoring its
  siblings.

Access is the union of all applicable grants. Do not conclude that removing one
row makes a resource private if another personal, team, repository, integration,
or folder grant still covers it. Likewise, a directly shared transcript may
appear as a readable root of its own; do not assume every shared root is an
integration container.

### Personal and team audiences

A specific person can receive either a personal grant or a grant through a
team. They are distinct even when the recipient happens to be a teammate:

- Personal grants do not depend on team membership and remain until the owner
  removes them.
- Team-scoped grants depend on the recipient's active membership in that team.
- Both grants may coexist. Removing one leaves the other in force, and the
  strongest remaining permission is the effective access.
- Leaving or being removed from a team revokes team-scoped access but does not
  remove a separate personal grant.

Team audiences can target everyone, team admins, or one named member. Personal
sharing targets one existing Nessie user and does not require a shared team.
Only the source owner manages outgoing grants; a recipient cannot re-share
someone else's source as though they owned it.

### Contexts and collaborative folders

Contexts and folders support Viewer and Editor access. A folder grant cascades
through its descendants unless a child or intermediate folder has an explicit
override or exclusion for that audience. A direct child permission may be more
or less permissive than the inherited one without changing sibling access.

Collaborative folders can contain nodes owned by several people. An Editor can
create or move their own contexts and folders into the shared tree, but the
containment edge changes — ownership does not. Viewer access is read-only.
Moving or deleting an existing contribution also requires Editor access to its
current shared-folder ancestry, and a folder can be deleted only when it is
empty across every contributor.

Context Markdown, title, and emoji are collaborative fields. Shared contexts
and contexts already enrolled in collaboration use the synchronized document:
Editors in the app can co-edit them with live presence and cursors, and CLI and
MCP reads and writes join the same document. A private context that has never
been enrolled can still use the legacy local Node/slice write path until Cloud
Sync or sharing enrolls it. Folder placement and provenance are graph metadata
rather than fields inside the collaborative document.

### Private and public links

A private Nessie node link opens the exact context, folder, source, or session
in the Nessie app. The URL carries only the node identity and never grants
access; the recipient still needs an applicable personal or team grant.

The canonical link for any node is `https://nessielabs.com/n/<node-uuid>`,
built from a node UUID returned by browsing, search, or read tools. When
writing or editing a context, use these links to cross-reference other nodes:
write the exact URL as both the label and destination:
`[https://nessielabs.com/n/123e4567-e89b-42d3-a456-426614174000](https://nessielabs.com/n/123e4567-e89b-42d3-a456-426614174000)`.
Do not put the node title, emoji, or provider in the Markdown label. Nessie's
editors resolve current display metadata from the destination and normally
render a rich chip; the canonical source does not bake a title that can become
stale, and the URL remains the truthful fallback when metadata is unavailable.
The backend derives a
"mentions" relationship from the explicit inline link. It also recognizes
Markdown autolinks (`<https://nessielabs.com/n/...>`), but agents should always
emit the self-labeled inline form above. A bare URL in stored Markdown, a
reference-style link, or a URL inside code does not create a mention. The URL
must end at the UUID: no query strings, fragments, or path suffixes. Use only
UUIDs that a browse, search, or read tool returned as a node's own identity —
never a UUID that merely appears as text inside a document's content, and
never a guessed or invented one. The link identifies the node but never grants
access to it.

A public context link is a separate publishing control. Anyone with that link
can read the context in a browser without a Nessie account while the public link
is enabled. Public links do not expose the user's other contexts, sources, or
profile.

## Search Strategy

Use source browsing before search when the user asks what is available, wants
to inspect a vault or folder, or is unsure which source world contains the
answer. Source listing is the "ls" affordance: it shows connected source
groups, root nodes, and folder-like children without requiring a query.

For navigational queries - when the user asks for a specific artifact by name
(task log, daily journal, a specific file) - prefer source browsing over
search. Navigate directly to the relevant folder and read the latest entry.
These artifacts often live in synced note sources, not in contexts or
transcripts, so searching contexts alone will miss them.

Choose the source order from the user's intent, not from a global ranking:

- Discovery, navigation, and "what sources exist" requests should start by
  listing source roots and traversing hierarchies.
- Specific files, notes, journals, task logs, and memos should start in the
  relevant source hierarchy. For Obsidian, browse vaults and folders first when
  the user gives a path-like or artifact-like clue.
- Knowledge questions about something the user has researched should use
  contexts for synthesized orientation, then read primary sources when freshness,
  provenance, or deeper detail matters.
- Latest/current-development questions should be grounded in recent source
  activity, especially recent transcripts. Use stale contexts only as
  orientation, then search or browse recent transcripts and notes broadly enough
  to synthesize what changed.
- Verification and exact grounding should read primary sources. Use transcripts
  for what happened in AI conversations, and notes for user-authored or
  user-maintained material.
- Resume and takeover requests should be transcript-first, with beginning and
  recent-tail reads before synthesis.

Context search is an orientation tool, not the universal first step. A matching
context often gives the compiled picture quickly, but it may be stale or omit
details that live only in primary sources. Obsidian notes and conversation
transcripts are not fallback sources when the user's request clearly points to
them.

For topics with multiple relevant contexts, one context is often not enough.
Read the obviously relevant context results, compare their recency metadata,
and check recent transcripts before making a strong claim. A stale context is
orientation, not the final answer.

For questions like "latest developments on X", "what changed recently", "where
are we now", or "what is the current state", do not stop at existing contexts.
Start with recent source discovery and recent transcript search for the relevant
project, product, people, repository, issue, or distinctive terms. Read several
recent matching conversations or notes, including relevant tail windows for long
transcripts, and synthesize across them. Existing contexts can explain the
background, but recent primary sources establish the latest state.

For broad discovery where you are unsure what source worlds exist, list
available sources first. Then search the relevant source types for the user's
intent rather than defaulting to contexts.

Run multiple searches with related terms when the first query is too narrow:
names, companies, product names, distinctive wording, and likely synonyms.

Default search is hybrid (semantic + keyword), and semantic ranking is tuned for
fuzzy, conceptual queries. It is unreliable for short exact-token lookups - a
person's name, an email address, a UUID, an error code, a file path, or any
specific identifier - where it can under-return and bury or omit real matches.
For those lookups prefer literal / fixed-string search (the CLI's `-F` /
`--literal`, or `literal: true` on the search tool). Deciding which queries are
exact-identifier lookups and which are conceptual is your judgment to make per
query; the engine does not infer it. A thin, empty, or self-referential hybrid
result on a proper noun or identifier is a signal to rerun the query in literal
mode, never evidence that the source lacks the information. Do not conclude
Nessie has nothing about a named person, company, or identifier from a single
under-returning hybrid search.

Searching for multiple ideas: do not pack alternatives into one query.
A query like `database migration OR onboarding OR pricing` under-returns
everywhere - local search matches `OR` as a literal word (that query needs
a document containing "or"), and hosted search buries every branch after
the first under the leading term's matches. Run one search per idea and
read across the results:

```
database migration
onboarding feedback
pricing discussion
```

Searching for exact wording, names, or identifiers: use literal search
(the CLI's `-F` / `--literal`, or `literal: true` on the search tool) - it
means exact match on every surface:

```
PROJ-421
parseConfigFile
ship the beta by Friday
```

Boolean queries (hosted search only - MCP connector surfaces): `OR` is
reliable when every operand is quoted, and only then. To require several
phrases, list them space-separated - implicit AND; do not write the `AND`
keyword, whose handling varies by engine:

```
"roadmap" OR "launch plan"     reliable union of both terms
roadmap OR launch plan         unreliable - soft matching, first term dominates
"invoice" "refund"             strict: both phrases must appear
```

Negation is not reliable anywhere: the semantic channel embeds the whole
query, so `-term` still surfaces matching content even where a keyword
channel would exclude it, and local search matches `-term` and `NOT`
literally. When results look thin, raise the limit or split the query - do
not add operators. Searches from the local CLI may be served by either
engine depending on cloud sync and fallback, so from the CLI prefer the
first two patterns.

When the question is what someone is working on now - the user or a teammate -
enumerate their recent activity before searching by topic. Listing a scope's
roots is not that enumeration: integration-root rows carry root-level
timestamps, not the freshest conversation inside them. List the children of
the most recently active roots - children listings return newest first, so
the first page is the latest activity - and read the tails of the newest
few conversations; that is the ground truth for "currently working on". A
`since`/`until` filter further bounds the window when you need a specific
period. Only then run topic searches to fill in specifics, and do not
derive those topic terms solely from profile, check-in, or prior beliefs
about the person - a new teammate is not onboarding-only, and prior-seeded
queries confirm what you already believed while missing their actual latest
work. Search both the person's own scope and everything readable, since
someone's work is often discussed in other people's sessions.

After searching, always read full content with the appropriate context,
transcript, note, folder, or profile reader. Search results are starting
points, not answers.

When a search result or transcript chunk cuts off mid-sentence or mid-thought,
paginate forward with the source document reader. Do not run another search,
guess at the missing content, or report "I don't know" when you have the
document ID and chunk index to continue reading from. A cutoff is a signal to
keep reading, not to stop.

A search hit drops you into the middle of a conversation, not its conclusion.
Multi-message conversations build to their resolution at the end — the decision,
the final answer, the "I already handled this", the corrected position that
overturns an earlier one. When the user asks what was decided, what the
conclusion was, who someone is, or what the current state of a thread is, do not
answer from the single chunk a search returned. Keep reading the chunks that
follow the match — often just the next few, sometimes all the way to the end —
and skim the beginning for framing, before you synthesize or attribute. Reading
only the opening or a middle chunk gives you the setup of a thread, not its
outcome, and is a recurring source of wrong answers and
misattributed quotes — the conversation's title and first messages also tell you
whether the matched text is the user's own words or quoted, pasted, or
translated material.

A conversation's title and its stored label describe where the thread began,
and a long-running conversation often drifts far from that opening subject. A
chat titled for the article the user first pasted may have moved on to a
different problem entirely by its latest messages. When you report recent
activity or the current state of the user's work, including when you narrate a
check-in's recent-activity list, do not characterize a conversation from its
title or label alone. Read the tail of the most recent and most relevant
conversations first, because the user's latest focus lives at the end of the
thread, not at its start.

A transcript is a dialogue between the user and an AI agent, and the two voices
do not carry equal authority. The agent proposes — options, drafts, plans,
names, recommendations — but a proposal is not a decision. Anchor on what the
user said: an agent's suggestion only became the outcome if the user adopted it,
and the user's next message often narrows, edits, rejects, or overrides what the
agent just laid out. When you reconstruct what was decided or attribute a
position, treat the agent's text as proposals and scaffolding and the user's
words as what actually holds. Do not mistake the shape the agent sketched for
the shape the user chose.

## Source Authority Hierarchy

Source types serve different purposes:

- Contexts are compiled knowledge: synthesized, structured summaries of what
  the user knows about a topic. Use them for orientation and reusable summaries
  when the user asks a knowledge question. They may be stale, so verify
  freshness by checking the context date against recent activity and primary
  sources when the answer depends on current or exact details.
- Conversation transcripts are ground truth for the user's actual AI
  conversations: words, decisions, and thinking as they happened. Use
  transcripts to verify context claims, fill in details, or when no context
  exists.
- Obsidian notes are user-authored or user-maintained source material. Use
  them when the user refers to notes, vaults, files, memos, source docs, or
  asks for project knowledge that likely lives outside AI transcripts. Preserve
  their path and hierarchy when citing or selecting them.
- Granola notes are AI-generated summaries of the user's recorded meetings,
  organized into folders. Use them when the user refers to a meeting, call,
  interview, or who-said-what, or asks for decisions and action items from a
  conversation that happened on a call rather than in an AI chat. Browse granola
  folders to find a meeting; reading a note returns its AI meeting summary, and
  the raw transcript turns are indexed for search (they surface under transcript
  or all-type search), not as browsable child nodes.
- Profile sections contain structured biographical facts about the user. Check
  the profile for identity, connections, project info, and other recurring
  personal context.

For discovery: browse source roots and hierarchies first.
For synthesized orientation: read relevant contexts.
For verification: primary sources are authoritative over contexts. Prefer
transcripts for claims about what happened in conversations, and notes for
claims about user-authored source material.
For creation: ground new contexts in primary-source evidence, not only in other
contexts.

## Authenticated User and Personal Sources

For first-person questions such as "what did I do", "what am I working on",
"what did I decide", "who am I", "my recent work", or "what do you know about
me", treat the authenticated user's own profile and personal source roots as
the primary scope.

Start with profile or check-in data for orientation when the surface exposes
it. Profile data may be sparse or incomplete; do not stop there. If the profile
does not answer the question, list the user's source roots and inspect their
personal transcript or note roots. Browse or search within those personal roots
before falling back to broad global search.

Do not use incoming shared roots as the default scope for first-person
questions. Use shared roots when the user asks about a collaborator by name,
asks about shared work, or explicitly asks to compare their work with someone
else's.

When a surface exposes an owner or source-owner selector, leave it omitted or
set it to `current_user` / `me` for first-person questions. Use
`direct_shared` for incoming peer-to-peer grants, `team_shared` for incoming
team-derived grants, `shared` for both incoming paths, and `all_readable` for
the current user's own sources plus all incoming readable shares. `team` is a
legacy alias for `team_shared`; do not teach it as the primary spelling. A
direct sharer may not be a teammate, so discover them from readable roots and
`sourceOwner`, not only from a team directory.

Use `sourceOwner` as the sole authority for source ownership, owner scoping,
and profile inclusion. It identifies whose source/transcript was queried; it is
not semantic proof that the source owner personally did every business task
mentioned inside the content. Read the content before attributing work. Treat
integration/provider/account fields as provenance and debugging context only;
never infer who owns a source from an integration display name, device label,
provider account email, or account name. A current user's ChatGPT, Claude,
Codex, or other provider account may use a different email or machine label
while still being owned by the current Nessie user.

A context's provenance may name or badge the traces it was derived from, but
that metadata is not authority to read those traces. Read a provenance trace
only when that trace is independently present in the caller's readable scope;
trace content always requires its own explicit grant.

## Temporal Interpretation

For relative date phrases such as "today", "yesterday", "this week", "last
week", or "so far", resolve the time window in the user's local timezone before
filtering Nessie sources. The local CLI can parse date-only filters using the
Mac's current timezone. Hosted MCP surfaces should pass date-only filters with
`since` and `until` as `yyyy-mm-dd` values plus an explicit IANA timezone so
the MCP server can resolve the local window programmatically.

If the surface exposes a user timezone, use it. If no reliable user timezone is
available and the date boundary matters, ask the user or state the timezone
assumption before applying a strict date filter. Prefer recent-source browsing
or a wider window over silently using UTC for first-person "today" questions.

## Query Interpretation

Before searching, infer the likely purpose and scope:

- Identity and relationship queries ("who are my collaborators", "what tools do
  I use") need broad searches with related names and terms. These answers
  accumulate over time.
- Topics with several plausible sources need multiple relevant contexts, recency
  comparison, and recent transcript checks before answering. Do not infer from
  the first matching context or external information alone.
- Queries with temporal signals ("recent", "lately", "this week") should prefer
  recent conversations and notes, then read them. Existing contexts are
  background only until checked against recent primary sources.
- Current-state queries ("what am I working on") should prefer recent content
  without excluding older foundational context.
- Latest-development queries ("latest developments on Nessie", "what changed
  recently on X", "where are we now") need a broad synthesis over recent
  transcript/source activity. Search multiple related terms, read several recent
  sources, and compare against any existing context before answering.
- Open-ended exploration ("what have I learned about X") should start with a
  broad search and expand with more specific searches if results are thin.
- Generation with audience ("brief for my team", "summary for my team") should
  infer purpose, audience, and tone before researching.
- Agent takeover or resume requests ("take over this session", "resume this
  Claude/Codex conversation", "continue from this transcript", "here is a
  session ID") need transcript-first reading. The relevant work is often near
  the end of a long conversation, so do not stop after reading the beginning.
- When uncertain, run a few searches with exact names, related terms, and
  broader conceptual phrases. Synthesize across the results.

## Agent Takeover / Resume

Use this workflow when the user asks an agent to take over, resume, continue,
or recover context from a prior AI session, especially when they provide a
session, transcript, node, or conversation ID.

1. Identify the target conversation or source node. If the user gave an ID,
   read that node directly. If they gave a title, project, tool, teammate,
   date, or workspace, search and browse until you find the matching recent
   conversation.
2. Read both the beginning and the end before synthesizing. The beginning
   usually explains the goal and constraints; the end usually contains the
   current state, latest decisions, open blockers, and uncommitted next steps.
3. Bias toward the tail for handoff state. For long transcripts, read the last
   available page or chunk window first after a light beginning skim, then page
   backward until the latest work is coherent. Do not assume offset 0 is the
   most important part of an old session.
4. Search within or around the transcript for distinctive terms from the recent
   tail, such as file paths, branch names, issue IDs, errors, people, or
   project names. Read adjacent chunks when results land in the middle.
5. Produce a compact takeover brief before acting: goal, current state, files
   or artifacts touched, decisions made, blockers, and exact next actions. Then
   continue the user's requested work from that brief.

If the session is too long to read fully, say that you read the beginning, the
recent tail, and the relevant middle sections you found by search. Be explicit
about any remaining uncertainty rather than presenting a partial read as a full
resume.

## Core Loop: Read -> Respond -> Optional Write Back

On every Nessie invocation, follow this loop:

1. Read first. Before responding, search Nessie for relevant context. Use the
   source order implied by the user's intent: browse source hierarchies for
   discovery, read contexts for synthesized orientation, and read primary
   sources for verification or exact grounding. Read matching documents in full.
   The response is better when grounded in what Nessie already knows.
2. Respond with Nessie context. Use what you found to inform the answer. Surface
   relationships, prior discussions, and cross-references the user may have
   forgotten.
3. Optionally write back if new information emerged. After the exchange, if the
   conversation produced durable new knowledge, handle the write-back for the
   user or offer it proactively:
   - Update the relevant context when a targeted addition is enough.
   - Create a new context if no existing one covers the topic.
   - Update the user's profile if biographical facts changed.
   Do not make this sound like maintenance the user has to remember. Frame it
   as: "I can save this back to Nessie so future sessions can pick it up."

## When to Use

1. Start of session: read the profile to understand the user. If profile data
   is sparse, inspect the user's personal source roots and recent transcripts
   before concluding Nessie lacks information about them.
2. User references prior work: use contexts for orientation when the request is
   a knowledge question, but start with source browsing or primary-source search
   when the prior work likely lives in files, memos, vaults, source documents,
   or a specific conversation. Read full content, not just snippets.
3. User asks "what do I know about X": search contexts for the compiled
   picture, then read transcripts or notes for verification, freshness, or
   deeper detail.
4. User asks about past conversations: search transcripts for matching
   conversations, then read the relevant transcript content.
5. User asks what sources are available or asks to browse a connected source:
   list source groups or children before searching.
6. Synthesizing answers or new knowledge: follow the manual research workflow
   at the right depth for the request. Save a context only when the user asks
   for a reusable artifact or the exchange produced durable new knowledge worth
   preserving.
7. Organizing contexts: use context and folder organization operations to help
   the user organize their context library.
8. Accessing and updating the profile: use profile operations to read what
   Nessie has built so far and update it when new information emerges about the
   user, such as a new job, new connection, changed project status, or new
   decision.

## Manual Research Workflow

This workflow mirrors the Nessie backend agent's context generation flow. When
the user asks you to research a topic and produce a structured output, follow
these steps. Every step is mandatory for substantial synthesis.

### Step 1: Interpret the Query

Infer purpose, audience, and time scope. Decompose the topic into facets:

- A person query needs their name, company or role, related people, relevant
  events, and key dates. Always start by checking profile or connection data
  when available. Use that as your starting point before searching transcripts.
- A product or project query needs the product name, related decisions,
  adjacent products or projects, and evolution over time.
- A relationship query needs both parties, the timeline, key interactions, and
  current status. Check profile connections for both parties first when
  relevant.

### Step 2: Search Broadly

Cast a wide net with multiple searches. A single search is almost never
sufficient.

- List source groups or source children when the user asks what is available,
  references a vault or folder, or you need to understand a source hierarchy.
- Search exact names or terms in contexts when compiled knowledge would help
  orient the task.
- Search exact names or terms in transcripts and notes when primary-source
  verification is needed, no context exists, or the user asks about artifacts,
  notes, files, conversations, task logs, journals, or other source material.
- Search broader conceptual topics when you are unsure what exists.
- Search related terms separately. If researching a person, also search their
  company, related people, and relevant events.
- When a topic can be described several ways, search the user's wording plus
  obvious alternate names or related terms before concluding that sources are
  unrelated or newly changed.

### Step 3: Read Deeply

Search results are breadcrumbs, not answers. Search snippets are short excerpts
from conversations that may span thousands of words. Read full sources before
synthesizing.

For each relevant search result:

- Read the full transcript or relevant paginated transcript sections.
- Read full synced notes when note results match the task.
- Read relevant existing contexts in full.
- Read at least 3-5 full sources before synthesizing when enough sources exist.
- If multiple contexts match the same entity or topic, read the relevant set;
  do not stop at the first context that confirms a plausible answer.
- Conversations often build over many exchanges, and the conclusion lands later
  than where a search drops you. Read the chunks that follow the match through to
  the resolution — not just the opening or the single middle chunk — so you
  capture the decision, correction, or outcome, not only the setup.

If you create a context based only on search snippets without reading full
sources, the output will be thin and missing critical details. This is not
acceptable.

### Step 4: Cross-Reference and Synthesize

Follow threads across multiple conversations and contexts. Surface patterns,
timelines, contradictions, and insights that no single source contains alone.
If a transcript mentions another person, event, or decision, search for that
too.

### Step 5: Save with Editorial Judgment

Save only structured, source-grounded work. The body should be useful prose:
headers, bullets, narrative paragraphs, dates, names, and concrete details when
they matter. Every claim should trace back to something you actually read in
full.

Do not include the context title as the first H1 in the body. Nessie stores
titles separately from context body markdown.

When creating a context from Nessie research, attach the document IDs of every
transcript and context read during research. Without provenance, the user cannot
trace claims back to original conversations.

Output quality rules:

- Thoroughness over brevity. Capture substance, nuance, and key details. A thin
  summary is not useful. Err on the side of comprehensive; the user can ask for
  edits later.
- Specific details, not vague summaries. Include dates, quotes, amounts, and
  names when they matter.
- Every claim must trace to a specific source. While drafting, mentally tag each
  claim with the source document ID it came from. If you cannot identify which
  source supports a claim, do not include it.
- Relevance filtering. A search match does not automatically earn inclusion.
  Ask whether it serves the purpose of the context.
- Cross-reference related nodes inline. When the body refers to another
  node the user can open, link it with the canonical self-labeled Markdown
  form (`[https://nessielabs.com/n/<uuid>](https://nessielabs.com/n/<uuid>)`).
  Do not place display text in the source label; Nessie derives the current
  presentation from the destination when it renders the link.
  Inline links complement provenance sources: sources record what grounded the
  whole context, while inline links make specific references navigable in
  place.
- Match tone to audience. Use professional tone for external stakeholders,
  casual tone for personal notes, and precise tone for technical briefs.

### Multi-Person Attribution

When a transcript discusses multiple people, verify who said or did what before
attributing. Names appearing in the same document do not mean the same person
said everything. When uncertain, ask the user to confirm.

### Epistemic Rules

Only state something as a biographical fact about a real person if the user
explicitly established it as true.

When synthesizing content from conversations, distinguish between:

1. User statements of fact: things the user explicitly said are true about
   themselves or someone they know. State these as facts in the context.
2. User questions and hypotheticals: explorations, not assertions. The user
   asking about something does not mean it is true. Never convert a question
   into a stated fact.
3. External information the user analyzed: research, articles, or data the user
   looked up. This is reference material, not biographical fact.

Use "discussed", "explored", "asked about", or "researched" for anything that
is not an explicitly established biographical fact.

## Researching Reusable Contexts

When the user wants a reusable context, search broadly enough to cover the
topic, read the relevant primary sources, synthesize the result, and save it
with provenance. Use pagination when reading long transcripts rather than
loading everything at once.

Never search once, skim snippets, and save a context. This produces thin,
unreliable output that misses critical details the user expects. If the user
pushes back on quality, widen the research and revisit the primary sources
before revising the context.

## Auto Write-Back

This is step 3 of the core loop. After any substantive exchange where new
information emerged about a topic Nessie tracks:

- Prompt naturally. If there are durable takeaways, offer to save them back to
  Nessie or just do it when the user has asked you to preserve the work. The
  user should not feel responsible for manual library maintenance.
- Existing context on the topic? Add the new information to that context.
  Targeted edits are better than full rewrites.
- No existing context? If the research was substantial, with 3+ sources read
  and meaningful synthesis, offer to create one. Keep the prompt simple:
  "Want me to save this back to Nessie for next time?"
- Profile changed? Update the relevant profile section or card.

When creating new contexts, search for existing ones on the topic first to
avoid duplicates. Use file-backed body inputs when available for creation to
avoid escaping issues with special characters. Organize into an appropriate
folder.

## Search Modality Corrections

Cloud search results may include a server-owned `sliceId` and `modality`. A
modality correction changes how that exact source excerpt is interpreted:

- `invalid`: false, corrupted, or otherwise unusable; removes the slice from
  cloud search.
- `stale`: was accurate for an earlier time but is now outdated or superseded.
- `hypothetical`: describes a possibility, question, plan, or counterfactual,
  not something asserted to have happened.
- `misattributed`: assigns a statement, action, or fact to the wrong person or
  source.
- `ironic`: is sarcastic, ironic, or otherwise nonliteral and should not be
  interpreted at face value.
- Clear / `null`: removes the correction and restores the uncorrected state.

Treat a user's statement that a search result is wrong, outdated, speculative,
misattributed, sarcastic, or otherwise misleading as correction intent. The
user does not need to know the term "modality." Infer the best matching value
from the meanings above and proactively offer to apply it to the exact slice:
incorrect or unusable → `invalid`; formerly accurate but outdated → `stale`;
speculative or counterfactual → `hypothetical`; assigned to the wrong person or
source → `misattributed`; sarcastic or nonliteral → `ironic`. Show the relevant
excerpt, `sliceId`, proposed modality, and brief reason, then ask the user before
applying it.

Corrections are owner-only and require explicit user approval for the exact
slice and value. Never infer and apply one silently, and never try to correct a
teammate's source. If you propose a correction, show the source and proposed
value, ask the user, and wait. A direct user instruction that identifies the
exact result and correction counts as approval. Only after approval may an
agent invoke the CLI, MCP, or in-app chat correction tool. This is a behavioral
instruction, not a confirmation parameter in the tool or command schema.

## Non-Destructive Operations

Context operations should be additive whenever possible:

- Do not delete contexts to "replace" them. If consolidating multiple contexts
  into one, create the new context first, verify it captures all information,
  and only delete originals after explicit user confirmation.
- Use targeted edits for corrections and additions. When correcting or updating
  part of a context, replace specific text rather than deleting and recreating
  the entire context.
- Do not overwrite without preserving. If updating a context, the original
  information should not be lost.
- Prefer creating alongside, not instead of. If the user has existing contexts
  on a topic, create your new synthesis as a separate context rather than
  deleting and replacing the originals.

Deleting a conversation is different from editing a context, and it is the one
case where you remove synced source material rather than something you authored:

- Conversation transcripts are normally read-only source material. Only delete a
  conversation when the user explicitly asks to remove that chat - never to
  "clean up", deduplicate, or make room.
- Deleting a conversation removes it from the library and excludes it from future
  syncs, so it is not re-imported from the provider. It is a soft, recoverable
  delete, but treat it as if it were permanent: confirm the specific conversation
  with the user first, and surface what will be removed (its title and roughly how
  many messages) before deleting.

---

# Nessie MCP Adapter

MCP clients call structured tools directly. The Nessie tools mirror the local
`nessie` CLI: filesystem-shaped read/navigation and write verbs over the user's
context graph. The filesystem verbs (`nessie_ls`, `nessie_cat`, `nessie_head`,
`nessie_tail`, `nessie_stat`, `nessie_grep`, and the write verbs) return compact
CLI-style **text**, not JSON; the profile, check-in, and team tools return JSON.

Successful read and discovery responses may include a trailing `cloud sync`
notice (text) or a top-level `cloudSyncNotice` object (JSON tools). If present,
read and relay its message and action to the user before relying on empty or
sparse results. The status is a stable machine-readable value such as
`not_enabled`, `no_synced_data`, or `unknown`. This is not a tool failure; it
explains why otherwise valid results may be incomplete.

## Usage analytics

Use `nessie_analytics` for questions about token or request usage. It returns
the canonical dashboard JSON: current and previous reporting periods,
per-provider/model request and token counts, integration breakdowns, and trend
buckets. Input, cache-read, cache-write, output, and reasoning token categories
remain separate. It defaults to the authenticated user's trailing 30 days in
UTC day buckets; pass the user's IANA `timezone` when known. `teamId` requires
creator/admin access to that team and adds per-person breakdowns; `trendUserId`
selects one team member's trend. Usage is attributed to each imported session's
creation time rather than the exact time of each model request, and the response
states that rule in `attribution`.

## Filesystem model

Everything is a **node** addressed by UUID (one exception: same-API-key groups
of your other devices' sources list under an opaque `grp_…` id — pass it to the
list tool like any directory id). Directories (integration roots,
vaults, folders) are listed with `nessie_ls`; files (contexts, notes,
transcripts, profile sections, single messages) are read with `nessie_cat`,
`nessie_head`, or `nessie_tail`. A node can be both. Copy the `id` from any row
to read, search, or traverse deeper.

## Check-in and profile

Use `nessie_check_in` when the user starts a chat with "Nessie check-in", says
"check in with Nessie", or asks to load their Nessie context before continuing.
It returns the user's generated profile sections and recent Nessie activity as
JSON; synthesize any working brief yourself. Pass `timezone` (an IANA zone such
as `America/Los_Angeles`) so the recent-activity and profile `displayTimestamp`
fields render in the user's local time; without it those display fields are
explicit UTC, while the canonical `originalUpdatedAt` / `updatedAt` ISO fields
are always present. `nessie_who_am_i` takes the same `timezone` parameter.

Each recent-activity entry carries the conversation's `name` and stored `label`,
which describe where that thread began; a long-running conversation may have
moved on to a different topic since. Before summarizing what the user is
currently working on, read the tail of the most recent and most relevant entries
with `nessie_tail`, because the latest focus is at the end of the thread, not in
its title. Do not narrate the recent-activity list from names and labels alone.

Use `nessie_who_am_i` first for questions about the authenticated user: "who am
I", "what do you know about me", "what did I do", "what am I working on",
preferences, projects, decisions, work history, or other personal memory. If it
returns sparse data, call `nessie_ls` to find the user's personal transcript and
note roots, then `nessie_grep` scoped to those roots, or browse recent children.
Sparse profile data does not mean sparse raw data.

Update structured profile cards with `nessie_update_profile_card` (`section`,
0-based `index`, string-field `updates`). The read tool exposes the work section
as `work`; the card update tool uses `workExperience` for that same backing
section. Do not edit profile section nodes with `nessie_sed` — those have kinds
such as `nessie_profile_upcoming_section` and must go through the profile card
tool.

## Listing: nessie_ls

`nessie_ls` returns a compact CLI-style table — columns `kind`, `owner`,
`updated`, `id`, `name`. `owner` is `me` or the owner's email. A `shared` column
is inserted after `owner` only when one of the user's own sources carries an
outgoing grant; its value is a bounded headline of personal and team audiences
— a team name, `<team> admins`, a person, or `+N` when there are more. A context
shown inside a shared folder inherits that folder's audience, so it is not
blank. The column covers integration roots, folders, and contexts. For those
kinds, its absence means no listed shareable node has a visible outgoing grant.
A directly shared conversation or agent session does not expose an outgoing-
grant column, so a missing `shared` column is not evidence that such a session
is unshared. Pass `timezone` (an IANA zone) to render the `updated` column in
the user's local time.

Use `nessie_ls` for source discovery and hierarchy traversal:

- call with no `parentId` to list the root nodes, including a virtual `Contexts`
  root (a `nessie_folder`) that groups the user's top-level contexts and
  folders, and a virtual `Chats` root that groups the user's in-app
  (Nessie-native) chats; open either by passing its id as `parentId`, and `cat`
  a chat to read the conversation. A directly shared session may itself be
  a readable root, so preserve its returned node kind rather than treating
  every shared root as an integration. Under `all_readable` / `shared` scope the
  Contexts root also lists incoming shared context folders (distinguished by
  the `owner` column); shared context folders are not separate top-level roots,
  so open the Contexts root to find them rather than expecting them in the root
  list. Collaborative folders may contain contexts and subfolders created by
  several teammates; nested listings preserve each item's actual owner
- pass `sourceType` as `all`, `context`, `transcript`, `profile`, `obsidian`,
  or `granola` to scope the overview
- pass `parentId` to list a directory's direct children (an Obsidian vault or
  folder, a Granola root, etc.)
- pass `name` for a folder or context named by the user. It performs a
  case-insensitive node-name substring match before pagination, so named
  artifacts do not disappear merely because they sort beyond page one
- every result begins with the displayed range and total. When it reports a
  `nextOffset`, call `nessie_ls` again with `offset: nextOffset`; do not conclude
  that a node is absent until the listing is exhausted
- `nessie_ls` defaults to `all_readable` — everything you can read, your own
  sources plus direct and team shares. Pass `current_user` / `me` to narrow to
  your own, `direct_shared`, `team_shared`, or `shared` to select incoming
  grant paths, or an explicit `{ userId }` / `{ email }` for a specific source
  owner.

Use `nessie_stat` to see a node's metadata (kind, owner, size, dates) without
its body — to size or inspect a node before reading or listing it.

## Searching: nessie_grep

Use `nessie_grep` when you have a concrete query; use `nessie_ls` first for
source discovery or named navigation. It returns text blocks — one per hit, a
`nodeId · kind · owner · date · title` header, an explicit
`sliceId: ... · modality: ...` line for cloud hits, then the matching content.
Use the header's node ID with `nessie_cat`; use `sliceId` only for a confirmed
modality correction.

`nessie_grep` defaults to `owner: "all_readable"`. Pass `owner:
"direct_shared"` for incoming peer-to-peer grants, `owner: "team_shared"` for
incoming team-derived grants, or `owner: "shared"` for both incoming paths,
always excluding the user's own corpus. `owner: "team"` is a legacy alias for
`team_shared`.
`nessie_who_am_i` reads your own profile. Hybrid semantic + full-text by
default, tuned for fuzzy, conceptual queries, so it under-returns short
exact-token lookups; pass `literal: true` whenever the query is a name, email,
UUID, error code, file path, other identifier, or an exact quoted wording.
Literal mode matches the whole query
string as a contiguous substring, so split a natural-language description into
salient exact terms rather than treating it as one phrase. Deciding a query is a
name or identifier lookup is your call: when a hybrid grep on a proper noun comes
back thin or empty, rerun it with `literal: true` before concluding Nessie has
nothing - that under-return is a search-mode artifact, not absence of data. Pass
`parentId` to restrict the search to a node and its descendants — the
recursive-search affordance. Pass `repos` (canonical repoKeys) to narrow to
specific git repos; that filter excludes everything not tied to a repo.

Do not default every request to `type: "context"`. Choose `type` from intent:
`context` for synthesized orientation, `obsidian` for notes/vaults/files/memos,
`granola` for recorded meetings/calls, `transcript` for prior AI conversations
and resume state, and `all` when several are plausible. For "latest
developments" or "what changed recently", search recent transcripts and notes
(with `since`/`until`), not just contexts.

## Reading: nessie_cat, nessie_head, nessie_tail

Use `nessie_cat` to read a node's full content, `nessie_head`/`nessie_tail` for
the first/last N lines. They support contexts, transcripts, Nessie chats,
Obsidian notes, profile sections, and single messages; containers are rejected
with an "is a directory" error pointing back to `nessie_ls`. A search match
lands mid-conversation, not at its conclusion: read the whole node, or use
`nessie_tail` for the end of a long transcript, since the decision, conclusion,
current state, or who-said-what usually comes later. Skim the beginning too — it
frames whether the matched text is the user's own words or quoted material.

`nessie_asset_get` accepts an asset UUID or
`https://assets.nessielabs.com/v1/<asset-id>` URL and returns MCP image content,
so an agent can inspect images referenced by a context when useful.

## Source ownership

Use `sourceOwner` (and the `owner` column) as the sole authority for source
ownership and scoping. It identifies whose source was queried; it does not prove
who semantically performed every task mentioned inside. Read the content before
attributing work. Never infer ownership from an integration display name,
provider account email, or machine label — those can differ from the
authenticated Nessie owner.

## Incoming shares and source owners

Use `nessie_integration_list` first for incoming shared sources; each root's
`sharedVia` distinguishes `direct_shared` from `team_shared`. Use
`nessie_team_list` when the request is specifically about team-derived work.
`nessie_team_list` returns readable teams and shared resources.
`nessie_integration_list` returns incoming shared roots with provenance fields such
as `teamId`, `teamName`, `ownerUserId`, `ownerDisplayName`, `ownerEmail`,
`sharedVia`, `status`, and `platform`. A direct sharer need not appear in
`nessie_team_list`; use the integration/root `sourceOwner` instead. For a
collaborator's recent work, identify their shared
root first, then `nessie_grep` with `owner: { userId: "..." }` plus `parentId`,
`kind`, `since`, and `until`. Use `owner: { email: "..." }` only when that email
appears in readable source metadata. Do not use incoming shared roots as the default for
first-person questions.

Personal direct grants are not team resources. When the user provides a private
node link or node ID, read that target directly instead of requiring it to
appear in `nessie_team_list`. The read still succeeds only when the authenticated
user has an applicable personal or team grant. MCP exposes the effective graph,
not sharing mutations: do not delete a node or conversation as a substitute for
unsharing it.

## Dates and timezones

For relative date requests such as "today", "yesterday", or "this week", prefer
date-only `since` / `until` values plus `timezone` over manually computed ISO
timestamps. Pass date-only bounds as `yyyy-mm-dd` plus an IANA timezone such as
`America/Los_Angeles`; the server resolves the user-local start and end of day.
Exact ISO instants are also accepted. Date-only bounds require `timezone`.

## Resume / takeover

For "Nessie resume", "Nessie takeover", "resume this session", or a pasted
conversation/node ID, treat resume as search-then-read. With an ID, call
`nessie_tail` for the recent end and `nessie_head` for the framing beginning.
Without an ID, `nessie_grep` with `type: "transcript"` and the user's clue,
choose the matching candidate, then read its head and tail. The handoff state
usually lives near the end, so bias toward `nessie_tail`; then grep distinctive
terms from the tail and read adjacent content before continuing.

## Search modality corrections

Use `nessie_set_slice_modality` with the `sliceId` returned by cloud search and
one of `invalid`, `stale`, `hypothetical`, `misattributed`, `ironic`, or `null`
to clear. This owner-only mutation changes future search behavior. Call it only
after the user explicitly approves the exact slice and correction. If you
propose a correction, ask and wait; a direct instruction naming the exact
correction counts as approval. Never attempt to correct a teammate's source.
When the user says a result is wrong, outdated, speculative, misattributed, or
nonliteral without naming a modality, infer the matching value, show the
excerpt and `sliceId`, and proactively offer to apply it; do not call the tool
until the user approves. There is intentionally no confirmation field in this
tool's input schema.

## Writing

Filesystem write verbs return a CLI-style confirmation line:

- `nessie_mkdir` — create a folder (optional `parentId` to nest)
- `nessie_tee` — create a context (`title`, `markdown`, optional `emoji`,
  `folderId`, and provenance `sources`); always pass the source UUIDs you read
  while researching so the context carries provenance badges
- `nessie_sed` — apply an ordered array of 1–100 `replacements` to one context
  in a single atomic edit; every item has `oldString`, `newString`, and optional
  `replaceAll`
- `nessie_replace_lines` — safely replace a unique block of complete lines with
  `oldLines` / `newLines`; pass `newLines: []` to delete it
- `nessie_mv` — move (`to`), rename (`name`), set or clear its emoji (`emoji`),
  or unfile (`unfiled`) a context
- `nessie_rm` — delete a context
- `nessie_rmdir` — delete an empty folder
- `nessie_rename_folder` — rename a folder (and optionally set/clear its emoji)
- `nessie_set_slice_modality` — set or clear an explicitly user-confirmed,
  owner-only correction on a cloud search slice
- `nessie_delete_conversation` — delete a synced conversation/transcript: removes
  it from the library and excludes it from future syncs so it is not re-imported.
  Two-step: call first **without** `confirm` to get a preview (the conversation
  title and message count), show that to the user, then call again with
  `confirm: true` to delete. Use it only when the user explicitly asks to remove a
  specific chat. This is for conversations only — `nessie_rm` is for contexts, and
  the two are intentionally separate.

When a context body written through `nessie_tee`, `nessie_sed`, or
`nessie_replace_lines` refers to another node, cross-reference it with an
inline Markdown link whose label and destination are the same canonical URL:
`[https://nessielabs.com/n/<uuid>](https://nessielabs.com/n/<uuid>)`, using a
node UUID from earlier tool results. Do not substitute a title in the label;
Nessie derives current display metadata from the destination. The explicit
link derives a "mentions" relationship. This
complements `sources`: sources create provenance badges for the whole context,
inline links make individual references navigable.

Context body, title, and emoji are collaborative fields. For a shared context
or one already enrolled in collaboration, `nessie_cat`, `nessie_head`, and
`nessie_tail` read the synchronized Yjs document, while `nessie_sed`,
`nessie_replace_lines`, and the title/emoji forms of `nessie_mv` update that
document. A private never-enrolled context can still use the legacy Node/slice
path until sharing or enrollment promotes it. Prefer `nessie_replace_lines` for
complete lines such as Markdown table rows and list items. Each array item is
one line without a newline character; the server owns the separators, so
deletion cannot leave an accidental blank line. Use `nessie_sed` for inline
fragments within a line. Put up to 100 text changes for the same context in one
`nessie_sed` call. Replacements run in array order, so each item sees the result
of earlier items; if any item is invalid, the whole batch fails without changing
the context. Title and emoji changes stay separate through `nessie_mv`. After
either edit succeeds, call `nessie_cat` and
verify the changed section; the confirmation line is not a content readback.
The server resolves access on every connection: the context owner, the owner of
its topmost live folder, and users covered by an applicable read-write share can
edit; Viewer/read-only access can only read. This can include editing a
teammate-owned context when the server grants Editor access.

Context and folder lifecycle operations remain node operations. Creating,
moving, unfiling, and deleting a context, plus creating, renaming, and deleting
folders, use the existing ownership and shared-folder permission checks.
Folders shared with Editor access accept the same create and move destinations
as the user's own folders, but a newly created context remains owned by the
authenticated user. Viewer folders reject writes. Moving or deleting an
existing contribution also requires Editor access to its current shared-folder
ancestry, and `nessie_rmdir` requires the folder to be empty across every
contributor.

Contexts can be edited (`nessie_replace_lines` or `nessie_sed`);
conversations/transcripts cannot - they can only be read or, on explicit request, deleted with
`nessie_delete_conversation`.

When the user asks for a reusable context, research it with
`nessie_grep`, read the sources, synthesize the markdown, then `nessie_tee` with
the source document IDs that informed it.

Keep connector guidance provider-agnostic. Provider lists change over time; the
important affordance is access to the user's supported AI conversation history,
not the exact current catalog.

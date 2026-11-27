# UI Tooling Preflight

Any UI check, verification or review requires BOTH of these to be installed and available:

1. **Playwright MCP** (real-browser testing, screenshots, accessibility, viewports)
2. **Impeccable plugin** (design critique/audit and the AI-slop detector)

## Step 0: Preflight (run BEFORE any other UI work)

### Check Playwright MCP
- Look for tools whose names start with `mcp__playwright__` (e.g. `mcp__playwright__browser_navigate`).
- If unsure, run `claude mcp list` and look for `playwright` with a connected status.

### Check Impeccable
- Look for the `impeccable` skill / `/impeccable` command in your available skills.
- If unsure, run `claude plugin list` and look for `impeccable`.

### If EITHER is missing: STOP

Do NOT continue. Do NOT fall back to code review, unit tests or "looks fine from the code".
Report this to the user, listing only what is missing:

> ⚠️ **UI verification is blocked: required tooling is not installed.**
>
> **Playwright MCP** (missing):
> `claude mcp add playwright -- npx @playwright/mcp@latest`
>
> **Impeccable plugin** (missing):
> `/plugin marketplace add pbakaus/impeccable`, then install `impeccable` from `/plugin`
> (alternative from the project root: `npx impeccable install`, then `/impeccable init` once per project)
>
> Restart Claude Code (or run `/reload-plugins`) after installing, then re-run this command.

If you are a subagent and cannot talk to the user, return that exact message as your result and mark the UI verification as **BLOCKED**, not passed.

## Always use both tools for UI verification

Whenever a UI check is performed, BOTH tools are mandatory, not optional:

- **Playwright MCP**: open the real app in a browser, perform the user flow, test the relevant viewports (mobile, tablet, desktop), check console errors, and save screenshots to `agent-os/specs/[this-spec]/verification/screenshots/`.
- **Impeccable**: run `/impeccable critique <target>` and `/impeccable audit <target>` on the changed UI (and `npx impeccable detect <changed UI paths>` if you can run the CLI). Treat P0/P1 audit findings and detector findings as failures to fix or to report. Run `/impeccable init` first if `PRODUCT.md` does not exist yet.

A UI check that used only one of the two is incomplete. Record in the verification output which Playwright flows and which Impeccable commands were run, and what they found.

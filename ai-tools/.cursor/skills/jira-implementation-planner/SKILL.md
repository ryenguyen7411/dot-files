---
name: jira-implementation-planner
description: Fetch Jira issue details via the Atlassian MCP integration and generate engineering-grade implementation plans. Use when the user provides Jira issue links (atlassian.net/browse/), issue keys (e.g. FINOPS-1234), or asks for a plan, implementation breakdown, estimation, or technical approach for Jira tickets.
---

# Jira Implementation Planner

## Activation

Activate when the message contains:
- `atlassian.net/browse/` URLs or issue keys matching `[A-Z]+-\d+`
- AND/OR terms: plan, implementation, breakdown, estimation, technical approach

If multiple issues are provided, process **all** of them.

---

## Step 1: Resolve Cloud ID

Before fetching issues, obtain the Atlassian Cloud ID:

```
CallMcpTool: server="user-Atlassian", toolName="getAccessibleAtlassianResources"
```

Use the returned `id` field as `cloudId` for all subsequent calls.

---

## Step 2: Fetch Issue Details

For each issue key, call:

```
CallMcpTool: server="user-Atlassian", toolName="getJiraIssue"
arguments: {
  "cloudId": "<cloudId>",
  "issueIdOrKey": "<ISSUE-KEY>",
  "fields": [
    "summary", "description", "issuetype", "status", "priority",
    "parent", "issuelinks", "comment", "labels", "components",
    "acceptance_criteria", "customfield_10016"
  ]
}
```

### Extract from the response:
- **summary** / **description** / **issuetype** / **status**
- **parent** - if present, fetch the parent issue too (same call)
- **issuelinks** - for blocks / is-blocked-by / relates-to / duplicates
- **comment.comments** - read ALL comments; they contain scope clarifications
- **Acceptance criteria** - check both `acceptance_criteria` and description for AC sections

### Linked issues

If issuelinks contain blocking or dependency relationships, fetch those issues if they affect implementation scope. Use `getJiraIssue` for each relevant linked issue.

---

## Step 3: Generate Implementation Plan

### Planning assumptions (unless ticket says otherwise)
- TypeScript codebase
- Frontend-heavy (React / SPA architecture)
- CI/CD pipeline exists
- Git branching strategy exists

### Planning rules

You MUST:
- Convert vague descriptions into concrete engineering tasks
- Identify missing requirements and call them out
- Separate concerns: UI / API / Validation / State / Permissions
- Distinguish refactors from new features
- Infer hidden work: migrations, edge cases, data shape impact
- Identify testing impact
- Include all relevant context from comments

You MUST NOT:
- Produce generic summaries or business-speak
- Skip comments (they often override or refine the description)
- Assume anything not stated in the ticket without flagging it

---

## Step 4: Output

Use the output template defined in [output-template.md](output-template.md).

**Single ticket** - produce the full plan for that ticket.

**Multiple tickets** - produce individual plans, then append a **Cross-Ticket Coordination Plan** covering:
- Shared components across tickets
- Recommended implementation order
- Merge strategy
- Risk of conflict between concurrent work

# Output Template

For each ticket, produce the following structure. Replace placeholders with actual content.

---

```markdown
# {ISSUE-KEY} – {SUMMARY}

## 1. Objective

Clear technical statement of what must be achieved. No business fluff.

---

## 2. Scope Breakdown

### 2.1 Functional Changes
- Explicit user-visible behavior changes
- Feature toggles if implied

### 2.2 Frontend Tasks
- Components to create/update
- State management changes
- API integration changes
- Form validation
- Permission handling
- Error states
- Loading states

### 2.3 Backend / API Impact (if applicable)
- Endpoint changes
- Data contract changes
- Required coordination with backend team

### 2.4 Data / Schema Considerations
- Field additions
- Migration concerns
- Backward compatibility

---

## 3. Dependencies

- Parent ticket impact
- Blocking issues
- Shared components
- External services

---

## 4. Risks & Ambiguities

Explicitly list:
- Missing acceptance criteria
- Conflicting comments
- Assumptions made (and why)

---

## 5. Suggested Technical Approach

Concrete strategy covering:
- Refactor vs incremental change
- Reuse existing abstractions vs create new ones
- Performance concerns
- Edge case handling

---

## 6. Testing Strategy

- Unit tests (specific areas)
- Integration tests
- E2E scenarios
- Regression surface affected

---

## 7. Suggested Task Breakdown (Subtasks)

Granular tasks at 0.5d–1d level, ordered logically:

| # | Task | Estimate |
|---|------|----------|
| 1 | ... | 0.5d |
| 2 | ... | 1d |

---

## 8. Suggested Branch Name

`feature/{ISSUE-KEY}-{short-slug}`
```

---

## Cross-Ticket Coordination Plan (multiple tickets only)

When multiple tickets are provided, append this section after all individual plans:

```markdown
# Cross-Ticket Coordination Plan

## Shared Components
- Components or modules touched by multiple tickets

## Recommended Implementation Order
1. Ticket X first because...
2. Ticket Y after X because...

## Merge Strategy
- Recommended merge order to minimize conflicts

## Risk of Conflict
- Files/modules with overlapping changes
- Mitigation approach
```

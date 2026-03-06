# PI Planning Template: {{PROJECT_NAME}}

> **SAFe Program Increment Planning** — Use this template to plan a full PI
> (typically 8-12 sprints). Copy this file, replace `{{placeholders}}`, and fill
> in each section. Sections map to standard SAFe PI Planning artifacts.
>
> **Source**: Production-validated at scale with 11 AI agents across 5 services.

---

## 1. Program Summary

**Program**: {{PROJECT_NAME}}
**PI Duration**: {{START_DATE}} — {{END_DATE}}
**Sprint Cadence**: {{SPRINT_LENGTH}} (e.g., 2 weeks)
**Sprint Count**: {{SPRINT_COUNT}}
**Decision Readiness**: {{READINESS_PERCENT}}%

### Feature Stream Breakdown

| Stream | Points | Tickets | Status | Sprint Range |
| ------ | ------ | ------- | ------ | ------------ |
| {{STREAM_1}} | {{PTS}} | {{TICKET_PREFIX}}-XXX–YYY | Not Started | S1-S3 |
| {{STREAM_2}} | {{PTS}} | {{TICKET_PREFIX}}-XXX–YYY | Not Started | S4-S6 |
| {{STREAM_3}} | {{PTS}} | {{TICKET_PREFIX}}-XXX–YYY | Not Started | S5-S8 |

### Program Totals

| Metric | Value |
| ------ | ----- |
| Committed points | {{COMMITTED_PTS}} |
| Backlog/deferred points | {{BACKLOG_PTS}} |
| Total if everything decomposed | {{TOTAL_PTS}} |
| Active tracker issues | {{ISSUE_COUNT}} |
| Feature streams | {{STREAM_COUNT}} |
| Services/packages | {{SERVICE_COUNT}} |

---

## 2. Program Board

The Program Board maps feature streams to sprints, showing when work starts and
flows across the PI. Each cell describes the key deliverable or milestone for
that stream in that sprint.

| Stream | Team | Pts | S1 | S2 | S3 | GATE | S4 | S5-S6 | S7-S8 | Notes |
| ------ | ---- | --- | -- | -- | -- | ---- | -- | ----- | ----- | ----- |
| {{STREAM_1}} | {{TEAM}} | {{PTS}} | Scaffold | Core | Tests | Review | — | — | — | |
| {{STREAM_2}} | {{TEAM}} | {{PTS}} | — | Design | Impl | Review | Hardening | — | — | |
| {{STREAM_3}} | {{TEAM}} | {{PTS}} | — | — | — | — | Scaffold | Core | Integration | |

> **Tip**: For agentic teams, include which agent role owns each sprint cell
> (e.g., "BSA: specs" in S1, "BE/FE: impl" in S2-S3, "QAS: validation" in S4).

---

## 3. Sprint Plans

### Sprint 1: {{SPRINT_1_DATES}}

**Capacity**: {{SPRINT_1_PTS}} pts

| ID | Description | Pts | Team | Dependencies | Notes |
| -- | ----------- | --- | ---- | ------------ | ----- |
| {{TICKET_PREFIX}}-XXX | {{DESCRIPTION}} | {{PTS}} | {{TEAM}} | — | |
| {{TICKET_PREFIX}}-XXX | {{DESCRIPTION}} | {{PTS}} | {{TEAM}} | {{DEP}} | |

### Sprint 2: {{SPRINT_2_DATES}}

**Capacity**: {{SPRINT_2_PTS}} pts

| ID | Description | Pts | Team | Dependencies | Notes |
| -- | ----------- | --- | ---- | ------------ | ----- |
| {{TICKET_PREFIX}}-XXX | {{DESCRIPTION}} | {{PTS}} | {{TEAM}} | — | |

> **Pattern**: Copy the sprint table for each sprint in the PI. Include only
> tickets committed to that sprint — backlog items stay in Section 5.

---

## 4. Delivery Teams

List all teams (human or agent) and their sprint allocations.

| Team | Prefix | S1 Tickets | S1 Pts | Scope |
| ---- | ------ | ---------- | ------ | ----- |
| {{TEAM_1}} | {{PREFIX}} | {{TICKET_PREFIX}}-XXX/YYY | {{PTS}} | {{SCOPE}} |
| {{TEAM_2}} | {{PREFIX}} | {{TICKET_PREFIX}}-XXX/YYY | {{PTS}} | {{SCOPE}} |

### Agent Team Mapping (if using agentic workflow)

| Agent Role | Responsibility | Gate Owner? |
| ---------- | -------------- | ----------- |
| BSA | Requirements, specs, acceptance criteria | No |
| System Architect | ADR compliance, pattern review | Yes |
| BE Developer | API routes, middleware, logging | No |
| FE Developer | UI components, client-side logic | No |
| Data Engineer | Database schema, security rules | No |
| QAS | Testing, AC validation, evidence | Yes |
| Security Engineer | Vulnerability scanning, auth review | Yes |
| Tech Writer | Documentation, markdown quality | No |
| RTE | PR creation, CI/CD monitoring | No |
| TDM | Blocker resolution, tracker updates | No |

> **Customize**: Remove agent roles you don't use. Add domain-specific roles as
> needed (e.g., ML Engineer, DPE, DevOps).

---

## 5. Phase 1-2 Enablers

Enabler stories are technical debt, infrastructure, or architectural work that
enables future features. In SAFe, these are first-class backlog items with
acceptance criteria.

### {{SERVICE_1}} Enablers ({{COUNT}} stories, {{PTS}} pts)

| ID | Title | Pts | Phase | Sprint | Dependencies |
| -- | ----- | --- | ----- | ------ | ------------ |
| {{TICKET_PREFIX}}-XXX | {{TITLE}} | {{PTS}} | 1 | S4 | — |
| {{TICKET_PREFIX}}-XXX | {{TITLE}} | {{PTS}} | 1 | S5 | {{DEP}} |

### {{SERVICE_2}} Enablers ({{COUNT}} stories, {{PTS}} pts)

| ID | Title | Pts | Phase | Sprint | Dependencies |
| -- | ----- | --- | ----- | ------ | ------------ |
| {{TICKET_PREFIX}}-XXX | {{TITLE}} | {{PTS}} | 1-2 | S5-S6 | — |

> **Pattern**: Group enablers by service or package. Each enabler should
> reference the ADR or architectural decision it implements.

---

## 6. Dependencies

Cross-team and cross-service dependencies mapped with type and sprint timing.

| ID | From | To | Type | Sprint | Status |
| -- | ---- | -- | ---- | ------ | ------ |
| D-1 | {{FROM}} | {{TO}} | Finish-Start | S1 wk1 | Active |
| D-2 | {{FROM}} | {{TO}} | Finish-Start | S1 → S2 | Active |
| D-3 | {{FROM}} | {{TO}} | Start-Start | S3 | Resolved |

### Dependency Types

- **Finish-Start**: B cannot start until A finishes
- **Start-Start**: B can start when A starts (parallel with coordination)
- **Finish-Finish**: B cannot finish until A finishes

> **Tip**: Review dependencies at every sprint boundary. Unresolved dependencies
> are the #1 cause of missed PI objectives in agentic workflows.

---

## 7. ROAM Risk Register

Classify each risk using SAFe's ROAM model:

- **R**esolved — No longer a risk
- **O**wned — Someone is actively mitigating
- **A**ccepted — Acknowledged, no action planned
- **M**itigated — Reduced to acceptable level

| ID | Risk | Impact | Probability | ROAM | Mitigation | Owner |
| -- | ---- | ------ | ----------- | ---- | ---------- | ----- |
| R-1 | {{RISK_DESCRIPTION}} | High | Medium | Owned | {{MITIGATION}} | {{OWNER}} |
| R-2 | {{RISK_DESCRIPTION}} | Medium | Medium | Mitigated | {{MITIGATION}} | {{OWNER}} |
| R-3 | {{RISK_DESCRIPTION}} | High | Low | Accepted | {{MITIGATION}} | {{OWNER}} |

### Common Agentic Workflow Risks

These risks apply to most SAFe programs using AI agents:

| Risk | Impact | Typical Mitigation |
| ---- | ------ | ------------------ |
| Agent velocity lower than projected | High | Use S1 as calibration sprint, adjust capacity |
| Parallel PRs cause merge conflicts | High | Merge queue, CODEOWNERS, rebase-first strategy |
| Context loss across agent sessions | Medium | Spec-driven workflow, CLAUDE.md, memory files |
| CI/CD pipeline bottleneck | Medium | Path-based triggers, parallel test jobs |
| Scope creep from backlog additions | High | Gate new items through POPM Decision Brief |

---

## 8. Gate Criteria

Phase gates define measurable criteria that must pass before the program
advances. Each criterion has an owner and a threshold.

### {{GATE_NAME}} — {{GATE_DATE}}

| # | Criterion | Threshold | Type | Owner |
| - | --------- | --------- | ---- | ----- |
| G-01 | {{CRITERION}} | {{THRESHOLD}} | Must | {{OWNER}} |
| G-02 | {{CRITERION}} | {{THRESHOLD}} | Must | {{OWNER}} |
| G-03 | {{CRITERION}} | {{THRESHOLD}} | Should | {{OWNER}} |

### Gate Types

- **Must**: Blocking — gate fails if not met
- **Should**: Non-blocking — tracked but does not prevent advancement
- **Stretch**: Aspirational — tracked for velocity calibration

> **Pattern**: Define gates at PI boundaries, not sprint boundaries. Sprint
> reviews validate progress; gates validate readiness to advance phases.

---

## 9. POPM Decisions

Track decisions that the Product Owner / Program Manager (POPM) needs to make.
Unresolved decisions block planning and should have deadlines.

### Resolved

| # | Decision | Status | Date | Impact |
| - | -------- | ------ | ---- | ------ |
| 1 | {{DECISION}} | DECIDED | {{DATE}} | {{IMPACT}} |

### Pending

| # | Decision | Status | Owner | Deadline |
| - | -------- | ------ | ----- | -------- |
| 2 | {{DECISION}} | PENDING | {{OWNER}} | {{DEADLINE}} |
| 3 | {{DECISION}} | PENDING | {{OWNER}} | {{DEADLINE}} |

> **Rule**: No pending decisions should remain unresolved past the PI Planning
> event. If a decision cannot be made, log it as a ROAM risk (Accepted) and
> define a spike to gather information.

---

## 10. PI Planning Update Log

Use this section to track mid-PI changes to scope, timeline, or capacity.
Reference the original planning data so deltas are visible.

### Update: {{DATE}}

**Source**: {{ANALYSIS_OR_EVENT}}

#### Revised Program Totals

| Metric | Previous | Updated | Delta |
| ------ | -------- | ------- | ----- |
| Committed points | {{PREV}} | {{NEW}} | {{DELTA}} |
| Sprint count | {{PREV}} | {{NEW}} | {{DELTA}} |
| Feature streams | {{PREV}} | {{NEW}} | {{DELTA}} |

#### New Streams Added

| Stream | Points | Tickets | Phase |
| ------ | ------ | ------- | ----- |
| {{STREAM}} | {{PTS}} | {{TICKET_PREFIX}}-XXX–YYY | {{PHASE}} |

#### New Risks Added

| ID | Risk | Impact | Mitigation |
| -- | ---- | ------ | ---------- |
| R-N | {{RISK}} | {{IMPACT}} | {{MITIGATION}} |

> **Pattern**: Append a new update section for each mid-PI change rather than
> modifying the original tables. This preserves audit trail and makes scope
> creep visible.

---

## Appendix: How to Use This Template

### For Human Teams

1. Copy this file to your project repo as `docs/PI_PLANNING.md`
2. Replace all `{{placeholders}}` with your project data
3. Fill in Sections 1-9 during your PI Planning event
4. Use Section 10 for mid-PI updates
5. Review at every sprint boundary and IP sprint

### For Agentic Teams

1. Copy this file and fill in during BSA planning sessions
2. Reference from `CLAUDE.md` so all agents have PI context
3. Use Section 4's agent mapping to assign sprint work
4. Gate criteria (Section 8) feed directly into CI/CD gates
5. ROAM risks (Section 7) inform TDM blocker escalation

### Companion Templates

- **`planning_template.md`** — Epic/Feature/Story decomposition (one level down)
- **`spec_template.md`** — Individual story specification (execution contract)

### Spreadsheet Alternative

This template can also be maintained as a spreadsheet (xlsx/Google Sheets) with
one tab per section. The markdown version is preferred for version control and
agent consumption, but either format works — keep one authoritative source.

---

_Template from [SAFe Agentic Workflow](https://github.com/bybren-llc/safe-agentic-workflow).
Based on production PI Planning across 5 services, 11 agent roles, ~800 story points._

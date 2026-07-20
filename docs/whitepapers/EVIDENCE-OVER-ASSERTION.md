# Evidence Over Assertion

## Two methods for running AI agents at scale, and what happened when we tested them on ourselves

**Audience**: anyone running AI agents on real software — and particularly the AI Captains.
**Status**: a field report, not a pitch. Every number below was measured, and the mistakes are included.

---

## The problem nobody names

Ask an AI agent to document your codebase and you will get documentation. It will be well
organised, confidently written, and plausible. Some of it will be wrong.

You will not know which parts.

This is the central difficulty of agentic development, and it does not go away with better models.
An agent that reads a README and summarises it produces a summary of the README — including the
parts of the README that stopped being true eleven commits ago. The output looks like knowledge.
It is actually a well-formatted echo.

Two methods address this from opposite directions. This paper describes both, then reports what
happened when we ran them against the repository that ships them.

---

## Part 1 — SAFe x AI-DLC: replacing the clock, not the structure

SAFe gives a delivery process its hierarchy: initiatives, features, stories, defined roles, a
Definition of Done, disciplined dependencies. That machinery works and is worth keeping.

Its *cadence* does not survive contact with agents. Sprints assume human squads working for a week
or two. A team of specialised agents can elaborate, build, and verify a coherent unit of work in
hours. Planning that into two-week increments wastes most of the capability and hides progress
behind ceremony.

So the fusion keeps SAFe's structure and replaces its clock with AWS's
[AI-Driven Development Life Cycle](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/).

| Concept | Replaces | Definition |
| --- | --- | --- |
| **Bolt** | The sprint | An hours-to-days swarm with an entry gate and a hard exit. Exits on **evidence**, not a date. |
| **Unit of Work** | The Feature | One coherent outcome. A project in the tracker. |
| **Mob Elaboration** | Sprint planning | Decompose, list unknowns, ask questions — **before** writing code. |
| **The loop** | The stand-up | AI plans → AI asks → **human validates business context** → AI executes. |

Two things make this more than a rename.

**A Bolt exits on evidence.** Not on a date, and not on "the tests passed." It exits when the work
is merged, the relevant gate is *real* and green, and evidence is posted. A green check that still
masks a failure is not an exit. This distinction turns out to be the whole ballgame — see Part 3.

**The human validation step is not optional.** Agents own the build; humans own the judgment.
Secrets, security policy, branch protection, risk thresholds, and signing the Definition of Done
route to a person with options and a recommendation. Remove that step and this is just SAFe with
more tokens.

It is an *alternative* cadence, not a replacement. The standard sprint path remains valid. If the
problem space is still unclear, run a spike — forcing an ambiguous epic into one Bolt just relocates
the ambiguity into the code.

---

## Part 2 — The OKF knowledge vault: making staleness computable

The second method attacks the trust problem directly.

A **vault** is a bundle of small markdown concepts — one per real artifact or idea — each with
structured frontmatter, each linked to its neighbours, each stamped with the commit its claims were
verified against. It is built on
[Open Knowledge Format v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
(Google, Apache-2.0), which supplies portability. The rigor layer on top is what supplies trust.

Four rules carry most of the weight:

**`verified_against` + `baseline_sha`.** Every concept records the commit its claims were checked
at. Staleness stops being a feeling and becomes a `git diff` over a watch-list. You can *compute*
which concepts a change invalidated.

**The anti-hallucination link rule.** Agents may link only to IDs present in the manifest. It is an
allowlist, not a suggestion. This is what lets dozens of parallel authoring agents produce a
coherent graph instead of a pile of confident broken references. Want to link something that does
not exist? Name it in prose without a link and report it.

**Stub, don't duplicate.** If knowledge lives in a source-of-truth document, the concept is a
map-card that cites it. Restating more than a paragraph means stop and link. A vault that copies
your docs has doubled your drift surface, not reduced it.

**Code wins over docs.** Name the helper actually called, not the one that should be called. Where
implementation contradicts documentation, record the implementation and note the discrepancy.

The build runs in four phases: **Extract** (turn source into fact digests), **Generate** (turn
digests into concepts), **Navigate** (build a reference door and a learning door), and **Verify** —
which is adversarial, and is where the value concentrates.

---

## Part 3 — What happened when we ran it on ourselves

The SAFe Agentic Workflow harness is not a web application. No routes, no ORM, no database tables.
That made it a good falsification test: the vault subsystem ships twelve deliberately
stack-agnostic concept types, and if they were secretly over-fitted to the web app they came from,
building this vault would expose it.

We ran the full method against the harness at commit `fd0fc6a`, as a SAFe x AI-DLC program — one
epic, six stories, four gated phases, roughly 60 agent invocations.

### The deliverable

| Measure | Result |
| --- | --- |
| Concepts | **221** |
| Distinct source files mapped | **366** |
| Concept types in use | 15 |
| Validator | **0 errors, 0 warnings** (`--strict-orphans`) |
| Markdown lint | **0 errors** across 251 files |
| Orphans | 34 → **0** — every concept reachable from a door |
| Invented links across 23 parallel authoring agents | **0** |

That last row is the one to notice. Twenty-three agents wrote 210 concepts in parallel against a
shared allowlist, and not one invented a link.

### The genericization held

Zero `adr` concepts were fabricated. There is no `docs/adr/` directory in this repo and the type
requires a source, so the agents declined to invent one — the failure mode the build documentation
explicitly predicted did not occur. Four new types (`provider`, `command`, `script`, `test-suite`)
covered the harness-shaped artifacts the shipped twelve could not.

### The findings were the dividend

The vault was the deliverable. The findings were worth more.

**86 concepts carry a documented drift clause. 52 carry an open question.** All evidence-backed.
The serious ones were not typos:

**A governance hole.** One provider surface (`agent_providers/`) defines a Release Train Engineer
step called *"Merge Pull Request"* that runs `gh pr merge --rebase --delete-branch`. The
authoritative surface states, in bold, **"You do NOT merge — final merge authority is human."** One
mirror grants an agent an authority the harness explicitly reserves for a person. The same mirror
strips the Stop-the-Line gate from two developer roles, and the QA mirror has no Exit Protocol at
all.

**Two known open issues, rediscovered independently from source.** A squash-versus-rebase policy
contradiction, and a manifest field documented as protective that the sync engine never reads. No
agent was told these issues existed. They were found by reading the code.

**Five silent portability defects** in the sync engine. On macOS, `sync_scope` parsing used a GNU-only
regex, so *every* configured domain was rejected and multi-domain sync silently degraded to one
directory. Rollback computed every backup's timestamp as epoch zero and reported "No backups
available" with backups sitting on disk. Patch generation aborted outright. All silent. All with
clean exit codes.

Why had none of this surfaced? **The test suite that would have caught it could not run on the
maintainer's machine.** One GNU-only construct aborted it before its first test. Zero of fourteen
tests had ever executed locally. CI runs Linux, where the bugs are invisible.

That is the pattern this whole method exists to expose: **a gate that cannot run where the work
happens is not a gate.** After the fixes, the local suite sweep went from 4 of 9 passing to 8 of 9.

---

## Part 4 — The part most write-ups leave out

A paper arguing "verify, don't assert" is only credible if it reports its own failures. Here are
ours.

**The author of this method got four claims wrong, and verification caught all four.**

Three were in the hand-written *golden examples* — the reference concepts held up as the quality
bar for every other agent. One claimed a permission grant was unique to a command when a second
command carried the identical grant. One claimed a ported command "never issues checkout, pull, or
branch" when the file does exactly that, on two visible lines. The third *understated* a finding,
which is how the merge-authority governance hole surfaced at all.

The root cause was identical every time: **a fact was repeated from a summary instead of read from
the file.**

A fifth was worse in kind. Asked to verify a portability claim, the author ran `grep -oP`, saw it
work, and declared the defect unreal. The `grep` on that PATH was a third-party build with Perl
regex support. Stock macOS `grep` rejects the flag outright. **A true finding was nearly deleted on
the strength of an invalid test.**

**The verification caught its own verifiers, too.** During correction, agents re-checked the
findings before applying them and caught errors in the *evidence*: a cited count of 66 was actually
69; a cited 83 changed lines was 56 once diff headers were excluded; one concept carried an entirely
fabricated caveat, which was removed rather than softened. Two further items were **flagged instead
of edited** — and one of those flags was itself wrong. Flagging rather than fixing prevented
injecting a false line reference into a document about verifiability.

**And the discipline caught a baseline error.** A navigation agent was handed a brief stating the
test sweep was "8 of 9 passing." It ran the suites itself, measured 4 of 9, and wrote the measured
figure. It was right: the fixes producing 8-of-9 lived on a different branch and were not in the
baseline the vault is stamped against. Writing post-fix numbers against a pre-fix commit would have
made `verified_against` a lie — the exact drift the system exists to prevent.

Three layers deep: verifiers catching authors, correctors catching verifiers, a reviewer catching
correctors. That is not a story about clever agents. It is a story about a process where being
wrong is *cheap and visible* rather than expensive and hidden.

---

## Part 5 — What we would tell you to steal

**Make staleness computable.** The single highest-leverage idea here is stamping every claim with
the commit it was verified at. Everything else is scaffolding around that one move.

**Give parallel agents an allowlist, not trust.** Zero invented links across 23 agents was not luck.
The manifest was a hard constraint, and unlinkable wants were reported rather than guessed.

**Frame verification as refutation.** An agent asked "is this accurate?" reads the concept, finds it
coherent, and says yes. An agent asked "prove this wrong" opens the file. Same model, same context,
different instruction, wildly different output. Verifiers were told explicitly: *do not report that
a concept is good — that is not an output.*

**Require evidence, not opinions.** Every finding carried a `file:line` or a command with its actual
output. Findings without evidence were rejected and re-run. This is what made it possible to trust
94 findings from agents that could each have been confidently wrong.

**Treat zero findings as a red flag.** If an adversarial pass returns nothing, the verifiers were too
gentle. Budget for findings and be suspicious of a clean sheet.

**Test where the work happens.** CI on Linux would never have found any of the five portability
defects. They were found by insisting on local verification on the machine the maintainer actually
uses — and by fixing the broken test *before* trusting anything it reported.

---

## Closing

The methods in this paper are not magic and they do not make agents correct. They make agents'
mistakes **visible, cheap, and attributable** — which is a different and more achievable goal.

The evidence for that claim is this paper's own contents. A build that produced a clean 221-concept
knowledge base also produced a list of five things its own author got wrong, each caught by a
mechanism described in the method. If the method did not work, that list would be empty, and you
should not have believed the rest.

---

## Sources

Everything above is traceable. The vault, the methodology layer, and the build process all live in
the repository:

- [SAFe x AI-DLC Methodology](../guides/SAFE-AI-DLC-METHODOLOGY.md) — the fusion, the vocabulary, and when *not* to use a Bolt
- [Knowledge Vault subsystem](../../knowledge-vault/README.md) — the format, the validator, the adoption playbook
- [SAW Vault Build](../../knowledge-vault/docs/SAW-VAULT-BUILD.md) — the exact runnable build prompt used here
- [The vault itself](../knowledge-vault/index.md) — 221 concepts; start at [start-here.md](../knowledge-vault/start-here.md)
- [Conventions](../knowledge-vault/_meta/CONVENTIONS.md) — the constitution the agents were held to
- [Build log](../knowledge-vault/log.md) — the dated record, including the corrections

**External**: [AI-Driven Development Life Cycle](https://aws.amazon.com/blogs/devops/ai-driven-development-life-cycle/) (AWS) ·
[Open Knowledge Format v0.1](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) (Google)

---

*With thanks to Jordan Urbs and the AI Captains community, whose interest brought most of this
repository's audience. This is written for them, and for anyone else who would rather see the
mistakes than a clean story.*

SAFe® is a registered trademark of Scaled Agile, Inc.

# Log

Newest first. Every pull request that touches the vault prepends an entry here.

An entry records **what changed, why (ticket reference), and the source SHA** the claims were
verified against. Deprecation is a log entry plus `status: deprecated` — never a silent deletion.

Remember: **a citation is not re-verification.** Only re-deriving a concept from its sources
bumps that concept's `timestamp` and `verified_against`.

## 2026-07-19

Starter bundle created. Replace this entry with your own first build.

An initial build entry should record the shape of what was mapped and how it was verified, for
example: *"N concepts across &lt;areas&gt;. Sources verified against commit `abc1234`. Built by a
multi-agent pipeline: E extraction agents, G generation agents, and V adversarial verifiers whose
F evidence-backed findings were all corrected; gated by the validator and markdownlint."*

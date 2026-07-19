---
type: guide
title: "SECURITY.md"
description: "SSoT stub: the security policy, reframing risk for a prompt-and-config harness rather than an executable application."
tags: [ssot-stub, security, process, hooks]
timestamp: 2026-07-19
status: active
domain: operations
sources:
  - "SECURITY.md"
verified_against: "fd0fc6a"
---

# SECURITY.md

144 lines of security policy for an artifact that ships no application code. Its central move is to
refuse the standard vulnerability taxonomy and rewrite it for a harness of prompts and config.

## The Reframing

Its threat table maps each traditional risk onto its harness equivalent: code vulnerabilities
become prompt injection, dependency exploits become skill and command misuse, auth bypasses become
agent boundary violations, and data breaches become sensitive data sitting in prompts. That last
mapping is why the vault records config and environment key names but never values.

## What Is Reportable

Five classes: prompt injection vectors, agent boundary bypasses, sensitive data exposure in
templates, hook command injection, and documentation that encourages insecure practice. The fifth
is the unusual one — here a bad instruction is a vulnerability, because the instruction executes.

Reporting timeline is acknowledgement within 48 hours and severity assessment within one week. In
scope: everything under `.claude/`, the agent definitions in `AGENTS.md`, the workflow templates,
and dangerous documentation. Out of scope: Claude Code itself, adopter application code,
third-party integrations, and example content.

## What Adopters Are Told To Check

Four concerns, in the document's order: that placeholder customization actually completed, that
agent boundaries are set via tool restrictions in `.claude/agents/`, that skill content has been
reviewed, and that hook scripts in `.claude/hooks-config.json` are safe. The second is procedural,
not aspirational — tool restriction is defined in
[Agent Configuration SOP](../sop/agent-configuration-sop.md); placeholder completion is auditable
via [TEMPLATE_SETUP.md](template-setup.md).

## Known Drift

- Its Supported Versions table lists 2.0.x as the current release and 1.x as deprecated, while the
  repository ships v2.10.0. The table has not been maintained; the shipped version is the truth.
- In the "Before Adoption" subsection the three shell commands are unfenced prose, and the third
  runs together with the following `### During Use` heading — so the heading renders inside the
  command. Do not copy that block verbatim.

## Citations

- [SECURITY.md](../../../../SECURITY.md) — the full policy; footer Version 2.0, last updated
  December 2025.
- [Security-First Architecture](../security/security-first-architecture.md) — design-side companion.

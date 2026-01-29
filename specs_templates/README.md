# Spec-Driven Workflow Templates

## Overview

This directory contains the master templates for the spec-driven workflow, which is the process for defining work in {{PROJECT_SHORT}} projects. All implementation tasks are guided by a detailed, version-controlled specification file (`spec.md`) that serves as the single source of truth.

## Templates

### `planning_template.md`

Used by the **Business Systems Analyst (BSA)** agent to decompose large initiatives from Confluence into a SAFe work breakdown structure:

- Epic → Features → Stories → Enablers

This is the first step in translating business needs into technical requirements.

### `spec_template.md`

The master template for a single unit of work (typically a Linear User Story). The BSA agent copies this template to create a new `{{TICKET_PREFIX}}-XXX-feature-name-spec.md` file for each task.

## The Specification as a Work Contract

A `spec.md` file is the formal "work contract" for an execution agent. It must be completed by the BSA before any implementation work begins.

### Key Sections:

- **Issue Reference**: Links back to the Linear ticket
- **High-Level Objective & User Stories**: Defines the "what" and "why"
- **Acceptance Criteria**: Testable outcomes that define "done"
- **Pattern References**: Which patterns from `patterns_library/` to use
- **Low-Level Tasks**: Step-by-step implementation guide
- **Testing Strategy**: Instructions for QAS agent validation
- **Pull Request Template**: Pre-filled template for consistency

## Metacognitive Handoff Notes

Critical feature for passing context from planning to execution agents using three tags:

### `#PATH_DECISION`

Documents **why** a particular architectural path was chosen over alternatives.

**Example**: `#PATH_DECISION: Chose REST over GraphQL due to existing API patterns and to avoid adding a new dependency.`

### `#PLAN_UNCERTAINTY`

Flags assumptions made during planning that require validation.

**Example**: `#PLAN_UNCERTAINTY: Assumed enrollment_close_at is optional - verify with POPM before making the field required.`

### `#EXPORT_CRITICAL`

Highlights non-negotiable requirements, security rules, or architectural constraints.

**Example**: `#EXPORT_CRITICAL: MUST use withAdminContext for all course_runs operations. No exceptions.`

## Workflow Process

1. **BSA** receives task from TDM or POPM
2. **BSA** copies appropriate template (`planning_template.md` for epics, `spec_template.md` for stories)
3. **BSA** performs pattern discovery and fills out spec completely
4. **BSA** includes metacognitive handoff notes
5. **Spec** is committed to repository
6. **Execution agent** reads ONLY the `spec.md` file and follows instructions precisely

This strict separation ensures thorough upfront planning and efficient, consistent execution.

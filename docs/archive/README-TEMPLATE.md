# {{PROJECT_SHORT}} SAFe-Agentic-Workflow Template

This repository provides a comprehensive template for establishing a sophisticated human-AI collaborative development workflow, inspired by the {{PROJECT_NAME}} ({{PROJECT_SHORT}}) project. It embodies principles of Evidence-Based Delivery, Pattern-Driven Development, and a Spec-Driven Workflow, all structured around a SAFe Agile Release Train (ART) model.

## 🚀 Quick Start

To integrate this workflow into your new or existing project, follow these steps:

1. **Navigate to your project's root directory.**

   ```bash
   cd /path/to/your/project
   ```

2. **Run the `apply-workflow.sh` script.**

   ```bash
   # First, clone this template repository to a temporary location
   git clone https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}.git /tmp/{{LINEAR_WORKSPACE}}-workflow-template

   # Then, run the script from your project's root
   bash /tmp/{{LINEAR_WORKSPACE}}-workflow-template/apply-workflow.sh
   ```

3. **Follow the interactive prompts.** The script will ask you to choose your AI agent provider (Claude Code or Augment) and provide project-specific details (e.g., ticket prefix, primary development branch).

4. **Complete Post-Setup Steps.** The script will guide you through any final manual steps, such as configuring GitHub secrets or reviewing provider-specific guides.

## ✨ Core Philosophy

This template enables a highly-structured, quality-focused, and efficient development process for a hybrid team of human and AI agents, built on:

- **Evidence-Based Delivery:** All work produces verifiable evidence (test results, session IDs) attached to project management tickets.
- **Pattern-Driven Development:** Mandatory reuse of pre-approved patterns for common tasks, enforcing consistency and accelerating development.
- **Spec-Driven Workflow:** Detailed, version-controlled `spec.md` files serve as the unambiguous source of truth for all implementation.
- **SAFe ART Model:** A team of 11 specialized AI agents, each with a distinct role, toolset, and recommended AI model, mimicking a real-world Agile Release Train.

## 🤖 AI Agent Provider Support

This template is designed to support multiple AI agent providers:

### 1. Claude Code (Primary, Automated Path)

- **Experience:** Fully automated, out-of-the-box setup.
- **Features:** Includes 11 pre-configured agent prompts, automated runtime hooks (for pattern reminders, RLS validation, Linear updates), and a master security policy.
- **Ideal for:** Teams using the Claude Code VS Code extension who want maximum automation.

### 2. Augment (Guided Starter Kit)

- **Experience:** A well-supported starting point with clear guidance for manual integration.
- **Features:** Includes pre-translated agent prompts (`instructions.md`, `rules/`) adapted from the Claude Code format, providing a functional base for Augment agents.
- **Guidance:** A detailed `AUGMENT_WORKFLOW_GUIDE.md` explains the automation gaps (e.g., no automated hooks) and provides manual alternatives, ensuring compliance with the workflow principles.
- **Ideal for:** Teams using the Augment CLI who want to integrate their agents into this structured workflow.

## 📂 Template Structure Overview

```
/your-project/
├── 📄 README.md                 # This file.
├── 📄 apply-workflow.sh         # Script to install the workflow.
│
├── 📂 .claude/                   # OR .augment/ (depending on choice)
│   ├── 📂 agents/                 # Agent prompts/instructions.
│   ├── 📂 hooks/                   # Automated scripts for Claude Code.
│   └── 📂 permissions/             # Tool access policies.
│
├── 📂 project_workflow/          # Core Git, CI/CD, and contribution guidelines.
│   ├── 📄 CONTRIBUTING.md
│   ├── 📂 .github/
│   └── 📂 scripts/
│
├── 📂 patterns_library/         # Reusable code patterns and solutions.
│   ├── 📄 README.md
│   └── ...
│
├── 📂 specs_templates/          # Templates for planning and specification documents.
│   ├── 📄 README.md
│   └── ...
│
└── 📂 linting_configs/          # Code quality and formatting configurations.
    └── ...
```

## 📚 Further Documentation

For a deeper dive into the philosophy, architecture, and implementation details of this workflow, please refer to:

- **[AGENTS.md](./AGENTS.md)** - Quick reference guide for the agent team
- **[CLAUDE.md](./CLAUDE.md)** - Claude Code specific configuration and guidelines
- **[CONTRIBUTING.md](./project_workflow/CONTRIBUTING.md)** - Complete contributor guide
- **[Pattern Library](./patterns_library/README.md)** - Reusable code patterns
- **[Spec Templates](./specs_templates/README.md)** - Planning and specification templates
- **[Workflow Documentation](./docs/workflow/)** - Workflow evolution and best practices
- **[Standard Operating Procedures](./docs/sop/)** - Agent workflow SOPs

> **Note**: Additional comprehensive documentation is available. For access to detailed architecture blueprints and implementation guides, please contact the maintainers.

## 🤝 Contributing

We welcome contributions! This template is designed to be adapted and improved by the community.

### Getting Started

1. **Read the Documentation**:
   - [Contributing Guidelines](./project_workflow/CONTRIBUTING.md) - Complete workflow guide
   - [AGENTS.md](./AGENTS.md) - Agent team quick reference
   - [Pattern Discovery Protocol](./patterns_library/README.md) - How to find and reuse patterns

2. **Report Issues**:
   - Found a bug? [Open an issue](https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}/issues)
   - Have a feature request? [Start a discussion](https://github.com/{{GITHUB_ORG}}/{{PROJECT_REPO}}/discussions)

3. **Submit Pull Requests**:
   - Follow the [CONTRIBUTING.md](./project_workflow/CONTRIBUTING.md) workflow
   - Use the PR template in `.github/pull_request_template.md`
   - Ensure all quality checks pass

### Code of Conduct

We are committed to providing a welcoming and inclusive environment. Please be respectful and professional in all interactions.

## 📖 Example Usage

After running `apply-workflow.sh`, your typical workflow will look like:

1. **Create a spec**: `cp specs_templates/spec_template.md specs/{{TICKET_PREFIX}}-123-my-feature-spec.md`
2. **Fill in requirements**: Define user story, acceptance criteria, tasks
3. **Implement using agents**: Follow the spec with agent collaboration
4. **Validate with demo script**: Run the demo script from spec
5. **Create PR**: Use the standardized PR template

See [AGENTS.md](./AGENTS.md) for detailed agent usage guide.

---

_Co-authored by Gemini (Google) and Auggie (ARCHitect-in-the-IDE)_

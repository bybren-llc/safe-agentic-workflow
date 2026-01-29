# Security Policy

## Project Security Context

This repository contains a **Claude Code harness** (configuration, prompts, workflows) rather than executable application code. Security considerations are different from traditional software:

| Traditional App                           | This Harness                   |
| ----------------------------------------- | ------------------------------ |
| Code vulnerabilities (XSS, SQL injection) | Prompt injection risks         |
| Dependency exploits                       | Skill/command misuse potential |
| Authentication bypasses                   | Agent boundary violations      |
| Data breaches                             | Sensitive data in prompts      |

## Supported Versions

| Version | Supported          | Notes                           |
| ------- | ------------------ | ------------------------------- |
| 2.0.x   | :white_check_mark: | Current release                 |
| 1.x.x   | :x:                | Deprecated, upgrade recommended |

## Security Considerations for Adopters

When adopting this harness, be aware of:

### 1. Placeholder Customization

- **Replace ALL placeholders** (`{{TICKET_PREFIX}}`, `{{PROJECT_NAME}}`, etc.) before use
- **Never commit secrets** in placeholder values
- Use environment variables for sensitive configuration

### 2. Agent Boundaries

- Agent prompts define **tool restrictions** for each role
- Review `.claude/agents/` before deployment
- Customize restrictions for your security requirements

### 3. Skill Content

- Skills in `.claude/skills/` are loaded into Claude's context
- Review skill content for any patterns that could leak sensitive info
- Custom skills should not contain credentials or internal URLs

### 4. Hook Scripts

- Hooks in `.claude/hooks-config.json` execute shell commands
- Review all hook commands before enabling
- Test hooks in a sandboxed environment first

## Reporting a Vulnerability

### What to Report

Please report:

- **Prompt injection vectors** in skills or commands
- **Agent boundary bypasses** that could escalate privileges
- **Sensitive data exposure** patterns in templates
- **Hook command injection** possibilities
- **Documentation that encourages insecure practices**

### How to Report

**For sensitive security issues:**

1. **Do NOT open a public GitHub issue**
2. Email: {{SECURITY_EMAIL}} (or your preferred contact)
3. Include:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact assessment
   - Suggested fix (if any)

**For low-severity issues:**

- Open a GitHub issue with the `security` label
- Use the bug report template

### Response Timeline

| Stage                  | Timeline              |
| ---------------------- | --------------------- |
| Initial acknowledgment | Within 48 hours       |
| Severity assessment    | Within 1 week         |
| Fix development        | Depends on severity   |
| Public disclosure      | After fix is released |

### What to Expect

- **Accepted**: We'll work on a fix, credit you in the changelog (unless you prefer anonymity), and coordinate disclosure timing with you.
- **Declined**: We'll explain why we don't consider it a security issue and suggest alternatives (e.g., documentation update, feature request).

## Security Best Practices for Users

### Before Adoption

# 1. Review all agent prompts

cat .claude/agents/\*.md

# 2. Review all hook commands

cat .claude/hooks-config.json

# 3. Review all skills for sensitive patterns

grep -r "password\|secret\|key\|token" .claude/skills/### During Use

- **Don't paste secrets** into Claude conversations
- **Review agent outputs** before executing suggested commands
- **Use the RTE agent** for release-critical operations (has additional checks)
- **Enable hooks** for automatic guardrails

### For Teams

- **Audit skill changes** in code review
- **Restrict who can modify** `.claude/` directory
- **Log agent invocations** if required for compliance
- **Train team members** on prompt security basics

## Scope

### In Scope

- All files in `.claude/` directory
- Agent definitions in `AGENTS.md`
- Workflow templates and patterns
- Documentation that could lead to insecure implementations

### Out of Scope

- Claude Code itself (report to Anthropic)
- Your project's application code
- Third-party integrations you add
- Issues in example/case study content (marked with 📚 EXAMPLE)

## Acknowledgments

We appreciate responsible disclosure and will acknowledge security researchers who help improve this project (with permission).

---

_This security policy follows the [GitHub Security Policy Guidelines](https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository)._

_Last updated: December 2025 | Version 2.0_

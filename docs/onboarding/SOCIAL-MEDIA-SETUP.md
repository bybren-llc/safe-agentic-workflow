# Social Media Setup Guide

How to configure social sharing for the SAFe Multi-Agent Development repository.

## 🎯 Overview

When someone shares your GitHub repository on social media (Twitter, LinkedIn, Slack, Discord), a **social preview card** appears with:

- Repository name
- Description
- Preview image
- GitHub logo

This guide shows how to optimize that preview.

---

## 📋 Quick Checklist

- [ ] Set repository description in GitHub Settings
- [ ] Add repository topics/tags
- [ ] Create social preview image (1200x630px)
- [ ] Upload image to GitHub Settings → Social preview
- [ ] Test with social media validators
- [ ] (Optional) Create custom landing page with Open Graph tags

---

## 1️⃣ Repository Description

### Current Recommended Description

```
Evidence-based multi-agent development methodology using Claude Code's Task tool.
11 specialized AI agents, SAFe framework, production-validated with real metrics.
MIT License.
```

**How to Update**:

1. Go to: {{GITHUB_REPO_URL}}
2. Click ⚙️ **Settings** (requires admin access)
3. Under "General" → "Description", paste the text
4. Click **Save**

---

## 2️⃣ Repository Topics

### Recommended Topics

Add these topics to improve discoverability:

```
ai-agents
claude-code
safe-framework
multi-agent-systems
software-development
agile-methodology
ai-assisted-development
developer-tools
anthropic
production-validated
```

**How to Add**:

1. Go to repository homepage: {{GITHUB_REPO_URL}}
2. Click ⚙️ (gear icon) next to "About"
3. Add topics in the "Topics" field (comma-separated)
4. Click **Save changes**

---

## 3️⃣ Social Preview Image

### Image Specifications

**Required Dimensions**: 1200 x 630 pixels (Open Graph standard)
**File Format**: PNG or JPEG
**Max File Size**: 1 MB
**Aspect Ratio**: 1.91:1

### Design Recommendations

**Content to Include**:

- **Project Name**: "SAFe Multi-Agent Development"
- **Tagline**: "Evidence-Based Multi-Agent Development with Claude Code"
- **Key Visual**: 11 agent icons or workflow diagram
- **Key Metric**: "169 Issues • 14× Velocity • 90.9% PR Merge Rate"
- **Production Validated Badge**

**Design Tools**:

- **Canva**: https://www.canva.com/create/open-graph-images/ (free templates)
- **Figma**: Community templates for Open Graph images
- **Photoshop/GIMP**: Full control
- **Online Tools**: https://opengraph.xyz/ (quick generation)

### Example Design Layout

```
┌──────────────────────────────────────────────────────────┐
│                                                          │
│   🤖 SAFe Multi-Agent Development                  │
│                                                          │
│   Evidence-Based Multi-Agent Development with Claude Code│
│                                                          │
│   [11 Agent Icons in a circle/workflow]                 │
│                                                          │
│   ✅ 169 Issues    📈 14× Velocity    🎯 90.9% PR Merge │
│                                                          │
│   Production-Validated  •  MIT License  •  github.com   │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

**Color Scheme**:

- Primary: GitHub dark (#0d1117)
- Accent: Claude purple (#9b87f5) or SAFe blue (#0078d4)
- Text: White (#ffffff) with good contrast

### Upload Instructions

1. Create image (1200x630px)
2. Save as PNG or JPEG (< 1 MB)
3. Go to: {{GITHUB_REPO_URL}}/settings
4. Scroll to **Social preview**
5. Click **Upload an image...**
6. Select your image
7. Adjust crop if needed
8. Click **Save**

---

## 4️⃣ Test Your Social Sharing

### Validation Tools

Test how your repository will appear on different platforms:

**Twitter/X Card Validator**:

```
https://cards-dev.twitter.com/validator
```

Enter: `{{GITHUB_REPO_URL}}`

**LinkedIn Post Inspector**:

```
https://www.linkedin.com/post-inspector/
```

**Facebook Sharing Debugger**:

```
https://developers.facebook.com/tools/debug/
```

**Slack Message Preview**:

- Just paste the URL in a Slack channel (preview updates automatically)

**Generic Open Graph Checker**:

```
https://www.opengraph.xyz/url/https%3A%2F%2Fgithub.com%2F{{GITHUB_ORG}}%2F{PROJECT_NAME}-Agentic-Workflow
```

### Clear Cache

If the preview doesn't update immediately:

1. Each platform caches social cards (24-48 hours)
2. Use validation tools to force a refresh
3. Wait and check again later

---

## 5️⃣ (Optional) Custom Landing Page

If you want MORE control over social sharing, create a GitHub Pages landing page with custom Open Graph tags.

### Create `index.html` in `docs/`

```html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />

    <!-- Primary Meta Tags -->
    <title>SAFe Multi-Agent Development</title>
    <meta name="title" content="SAFe Multi-Agent Development" />
    <meta
      name="description"
      content="Evidence-based multi-agent development methodology using Claude Code's Task tool. 11 specialized AI agents, SAFe framework, production-validated with real metrics."
    />

    <!-- Open Graph / Facebook -->
    <meta property="og:type" content="website" />
    <meta
      property="og:url"
      content="https://{{GITHUB_ORG}}.github.io/{{GITHUB_REPO}}/"
    />
    <meta property="og:title" content="SAFe Multi-Agent Development" />
    <meta
      property="og:description"
      content="Evidence-based multi-agent development methodology using Claude Code's Task tool. 11 specialized AI agents, SAFe framework, production-validated."
    />
    <meta
      property="og:image"
      content="https://{{GITHUB_ORG}}.github.io/{{GITHUB_REPO}}/social-preview.png"
    />

    <!-- Twitter -->
    <meta property="twitter:card" content="summary_large_image" />
    <meta
      property="twitter:url"
      content="https://{{GITHUB_ORG}}.github.io/{{GITHUB_REPO}}/"
    />
    <meta property="twitter:title" content="SAFe Multi-Agent Development" />
    <meta
      property="twitter:description"
      content="Evidence-based multi-agent development methodology using Claude Code's Task tool. 11 specialized AI agents, SAFe framework, production-validated."
    />
    <meta
      property="twitter:image"
      content="https://{{GITHUB_ORG}}.github.io/{{GITHUB_REPO}}/social-preview.png"
    />

    <!-- Redirect to GitHub repo -->
    <meta http-equiv="refresh" content="0; url={{GITHUB_REPO_URL}}" />
  </head>
  <body>
    <p>
      Redirecting to
      <a href="{{GITHUB_REPO_URL}}">SAFe Multi-Agent Development</a>...
    </p>
  </body>
</html>
```

### Enable GitHub Pages

1. Go to: Settings → Pages
2. Source: Deploy from a branch
3. Branch: `main` → `/docs`
4. Click **Save**
5. Wait for deployment (2-3 minutes)
6. Your landing page: `https://{{GITHUB_ORG}}.github.io/{{GITHUB_REPO}}/`

**Then share the GitHub Pages URL instead of the repo URL** for full Open Graph control.

---

## 6️⃣ Social Sharing Best Practices

### When Sharing on Different Platforms

**Twitter/X**:

```
🤖 Evidence-Based Multi-Agent Development with Claude Code

11 specialized AI agents • SAFe framework • Production-validated

✅ 169 Issues
📈 14× velocity growth
🎯 90.9% PR merge rate

Whitepaper + complete working template:
{{GITHUB_REPO_URL}}

#AI #Claude #AgenticAI #SoftwareDevelopment
```

**LinkedIn**:

```
🚀 Introducing SAFe Multi-Agent Development

After 5 months of production validation (169 issues, 2,193 commits),
I'm sharing our methodology for using Claude Code's Task tool with
11 specialized AI agents following the SAFe framework.

Key Results:
• 14× velocity improvement (Cycle 3→8)
• 90.9% PR merge rate
• Complete audit trail and evidence-based delivery
• "Round table" philosophy: equal voice for human and AI contributors

The repository includes:
✅ Complete whitepaper (12 sections)
✅ Production-validated patterns
✅ Agent configurations (Claude Code & Augment)
✅ Implementation templates

MIT License - Free to use and adapt for your team.

{{GITHUB_REPO_URL}}

What's your experience with multi-agent development?
Let's discuss in the comments.

#ArtificialIntelligence #SoftwareDevelopment #Agile #ClaudeCode #AI
```

**Reddit (r/Programming, r/MachineLearning)**:

```
Title: [Research] Evidence-Based Multi-Agent Development: 5 Months of Production Data

Body:
I've been using Claude Code's Task tool with 11 specialized AI agents
following SAFe methodology for the last 5 months. Just published the
complete whitepaper + working templates.

Key insights:
- 14× velocity improvement over 9 sprint cycles
- "Round table" philosophy: AI agents have "stop-the-line" authority
- Pattern discovery protocol: "Search First, Reuse Always, Create Only When Necessary"
- Evidence-based delivery with full audit trails

All metrics are verifiable (Linear API, GitHub API).

Repository: {{GITHUB_REPO_URL}}

Happy to answer questions about the methodology or implementation.
```

**Hacker News**:

```
Title: Evidence-Based Multi-Agent Development with Claude Code (5 months production data)

URL: {{GITHUB_REPO_URL}}
```

---

## 7️⃣ Repository Website Field

Set your repository's website field to your primary documentation or landing page:

**Options**:

- `https://{{PROJECT_DOMAIN}}` (your main site)
- `https://{{GITHUB_ORG}}.github.io/{{GITHUB_REPO}}/` (if you create GitHub Pages)
- A dedicated landing page on your domain

**How to Set**:

1. Repository homepage → Click ⚙️ next to "About"
2. In "Website" field, enter URL
3. Check ✅ "Use your GitHub Pages website"
4. Click **Save changes**

---

## 📊 Monitoring Social Sharing

Track how your repository is being shared:

### GitHub Insights

Go to: {{GITHUB_REPO_URL}}/graphs/traffic

- **Views**: Total repository views
- **Unique visitors**: Individual visitors
- **Clones**: Repository clones
- **Referring sites**: Where traffic comes from

### Analytics (Optional)

If you create a GitHub Pages landing page, add analytics:

**Google Analytics** (free):

```html
<!-- Add to <head> of index.html -->
<script
  async
  src="https://www.googletagmanager.com/gtag/js?id=G-XXXXXXXXXX"
></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag() {
    dataLayer.push(arguments);
  }
  gtag("js", new Date());
  gtag("config", "G-XXXXXXXXXX");
</script>
```

---

## 🎨 Assets Needed

### Checklist of Assets to Create

- [ ] **Social preview image** (1200x630px PNG/JPEG)
- [ ] **Repository icon** (circular logo, 512x512px)
- [ ] **Documentation hero image** (optional, for README)
- [ ] **Agent icons** (for diagrams, 11 unique icons)
- [ ] **Workflow diagrams** (for case studies)

**Storage Location**:

```
docs/assets/
├── social-preview.png          # Main social card (1200x630)
├── social-preview-square.png   # Square variant (1200x1200)
├── logo.png                    # Repository logo (512x512)
├── agents/                     # Individual agent icons
│   ├── bsa.png
│   ├── system-architect.png
│   └── ...
└── diagrams/                   # Workflow diagrams
    ├── workflow-overview.png
    └── agent-interaction.png
```

---

## ✅ Final Checklist

Before publishing:

- [ ] Repository description is clear and compelling
- [ ] Topics/tags are added (10+ relevant tags)
- [ ] Social preview image is uploaded (1200x630px)
- [ ] Image appears in social validators
- [ ] Repository website URL is set
- [ ] README.md has badges and clear structure
- [ ] LICENSE is set to MIT
- [ ] CITATION.bib and CITATION.cff are present
- [ ] All remote feature branches are deleted ✅
- [ ] Main branch is clean and up-to-date ✅

---

## 🚀 Launch Announcement Plan

### Phase 1: Initial Launch

1. Update repository description and social preview
2. Post on Twitter/X with image
3. Share on LinkedIn with detailed post
4. Post on relevant subreddits (r/Programming, r/ClaudeCode)

### Phase 2: Community Engagement

1. Hacker News submission (timing matters - Tuesday-Thursday morning PST)
2. Dev.to article with methodology walkthrough
3. Medium cross-post
4. Anthropic community forum post

### Phase 3: Long-term Promotion

1. Conference talk submissions (AI/ML conferences)
2. Academic paper submission (if appropriate)
3. Guest posts on relevant blogs
4. YouTube video walkthrough

---

**Last Updated**: 2025-10-08
**Status**: Ready for social media optimization
**Next Steps**: Create social preview image, upload to GitHub Settings

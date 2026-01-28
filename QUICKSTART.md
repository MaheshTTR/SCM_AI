# AI Agent Quick Start Guide

## What is the AI Agent?

The AI Agent is an automated system integrated into this repository's CI/CD pipeline that helps maintain code quality, security, and reliability through three main capabilities:

1. **🔒 Security Auto-Patching** - Automatically detects and patches security vulnerabilities
2. **🎯 Intelligent Risk Assessment** - Analyzes pull requests and assigns risk scores
3. **🤖 Autonomous Remediation** - Automatically fixes code quality and dependency issues

## How It Works

### On Every Pull Request
- AI analyzes changes and calculates a risk score (0-100)
- Posts a detailed risk assessment as a PR comment
- Flags high-risk changes for additional review
- Provides specific recommendations based on risk level

### On Every Push/Merge
- Runs security scans using CodeQL
- Generates AI-powered vulnerability assessments
- Identifies security issues that can be auto-fixed

### Daily Security Scans
- Runs comprehensive security analysis at 2 AM UTC
- Creates pull requests with security patches when needed
- Labels patches as `security`, `automated`, `ai-generated`

### Every 6 Hours
- Checks dependencies for vulnerabilities
- Scans code for quality issues
- Generates remediation reports

### On New Issues
- Automatically triages and labels issues
- Assigns priority levels
- Identifies issues eligible for auto-remediation

## Quick Commands

### Manually Trigger Security Scan
1. Go to **Actions** tab
2. Select **"AI Security Scan and Auto-Patch"**
3. Click **"Run workflow"**
4. Select branch and click **"Run workflow"**

### Manually Trigger Risk Assessment
1. Go to **Actions** tab
2. Select **"AI Risk Assessment"**
3. Click **"Run workflow"**
4. Select branch and click **"Run workflow"**

### Manually Trigger Remediation
1. Go to **Actions** tab
2. Select **"AI Autonomous Remediation"**
3. Click **"Run workflow"**
4. Choose remediation type:
   - **all** - Run all checks
   - **dependencies** - Only check dependencies
   - **security** - Only security issues
   - **code-quality** - Only code quality
5. Click **"Run workflow"**

## Understanding Risk Scores

| Score | Level | Meaning | Action |
|-------|-------|---------|--------|
| 0-39 | 🟢 LOW | Normal changes | Standard review process |
| 40-69 | 🟡 MEDIUM | Moderate impact | Extra attention needed |
| 70-100 | 🔴 HIGH | Significant changes | Additional reviews required |

### Risk Factors
- **File Count**: How many files changed
- **Line Changes**: How many lines added/removed
- **Sensitive Files**: Config files, secrets, credentials
- **Code Complexity**: Pattern analysis

## What to Expect

### On Your Pull Requests
You'll see a comment from the bot like this:

```
🤖 AI Risk Assessment Report

Risk Score: 45/100
Risk Level: MEDIUM

Files Changed: 8
Lines Added: 234
Lines Deleted: 45

⚡ Recommendations for MEDIUM Risk Changes
- ✅ Standard code review process
- ✅ Run integration tests
...
```

### Security Patches
If vulnerabilities are found, you'll see a new PR:

```
🤖 AI Security Auto-Patch

This PR contains automated security patches...
```

**Important**: Always review AI-generated patches before merging!

### Issue Triage
When you create an issue, you'll see:

```
🤖 AI Issue Triage

Classification: bug, medium-priority
Priority: medium
Auto-remediation candidate: No
```

## Configuration

Adjust AI behavior by editing `.ai-agent/config.yml`:

```yaml
risk_assessment:
  thresholds:
    high_risk: 70    # Adjust this to change sensitivity
    medium_risk: 40
```

## Viewing Reports

All AI reports are saved as artifacts:

1. Go to **Actions** → Select a workflow run
2. Scroll to **Artifacts** section
3. Download:
   - `ai-security-assessment`
   - `ai-risk-assessment-report`
   - `dependency-remediation-report`
   - `code-quality-remediation-report`

## Best Practices

✅ **DO:**
- Review all AI-generated PRs before merging
- Check risk assessments on your PRs
- Adjust thresholds if needed
- Monitor artifacts for detailed reports

❌ **DON'T:**
- Blindly merge AI patches without review
- Ignore high-risk warnings
- Disable workflows without understanding impact

## Troubleshooting

### "AI didn't comment on my PR"
- PRs from forks don't get comments (GitHub security)
- Check workflow logs for errors
- Ensure workflows are enabled

### "Risk score seems wrong"
- Adjust thresholds in `.ai-agent/config.yml`
- Consider your project's specific needs
- Risk scoring improves over time

### "Auto-patch didn't create PR"
- No vulnerabilities found (good!)
- Check workflow logs
- Ensure branch doesn't already exist

## Need Help?

- 📖 Full documentation: [.ai-agent/README.md](.ai-agent/README.md)
- 🐛 Found a bug? Create an issue
- 💡 Have suggestions? Create an issue with label `enhancement`

---

**AI Agent Version:** 1.0.0  
**Last Updated:** 2026-01-28

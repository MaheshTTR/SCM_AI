# SCM_AI
AI-powered Supply Chain Management system

## Deployment Workflows

This repository contains GitHub Actions workflows for automated deployment with self-healing capabilities.

### Available Workflows

- **BPMSClientService-QA-SiteA-SiteB-Deploy**: Deployment workflow for BPMSClientService to QA environments (SiteA and SiteB) with automatic rollback on failure

### Documentation

- [Deployment Guide](.github/DEPLOYMENT.md) - Comprehensive guide on the self-healing deployment workflow
- [Architecture](.github/ARCHITECTURE.md) - Technical architecture and flow diagrams
- [Quick Reference](.github/QUICK_REFERENCE.md) - Quick start guide with examples
- [Testing Guide](.github/TESTING_GUIDE.md) - Complete testing scenarios and validation steps
- [Summary](.github/SUMMARY.md) - Detailed change summary

### Key Features

✅ **Self-Healing Deployments**: Automatic rollback to previous version on failure  
✅ **Version Tracking**: Maintains deployment history for rollback purposes  
✅ **Smoke Testing**: Validates deployments before marking as successful  
✅ **Automatic Recovery**: Restores service to last known good state  
✅ **Access Control**: Team-based membership validation  
✅ **Critical Alerts**: Notifications when rollback fails requiring manual intervention

### Quick Start

1. Navigate to **Actions** tab in this repository
2. Select **BPMSClientService-QA-SiteA-SiteB-Deploy** workflow
3. Click **Run workflow**
4. Select environment (QA-SiteA or QA-SiteB)
5. Enter build version
6. Click **Run workflow**

For detailed usage instructions, see the [Deployment Guide](.github/DEPLOYMENT.md).

### Testing

Before using in production, please review and complete the [Testing Guide](.github/TESTING_GUIDE.md) which includes:
- 6 comprehensive test scenarios
- Validation checklists
- Troubleshooting procedures
- Emergency procedures

### Support

For issues or questions:
1. Check workflow logs in Actions tab
2. Review documentation in `.github/` directory
3. Contact SCM team
4. Create an issue in this repository

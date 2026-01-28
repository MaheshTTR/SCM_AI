# SCM_AI
AI-powered Supply Chain Management system

## Deployment Workflows

This repository contains GitHub Actions workflows for automated deployment with self-healing capabilities.

### Available Workflows

- **BPMSClientService-QA-SiteA-SiteB-Deploy**: Deployment workflow for BPMSClientService to QA environments (SiteA and SiteB) with automatic rollback on failure

### Documentation

- [Deployment Guide](.github/DEPLOYMENT.md) - Comprehensive guide on the self-healing deployment workflow
- [Architecture](.github/ARCHITECTURE.md) - Technical architecture and flow diagrams

### Key Features

✅ **Self-Healing Deployments**: Automatic rollback to previous version on failure  
✅ **Version Tracking**: Maintains deployment history for rollback purposes  
✅ **Smoke Testing**: Validates deployments before marking as successful  
✅ **Automatic Recovery**: Restores service to last known good state  
✅ **Access Control**: Team-based membership validation

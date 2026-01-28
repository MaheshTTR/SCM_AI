# Self-Healing Deployment Workflow

## Overview
This document describes the self-healing deployment workflow for BPMSClientService to QA environments (SiteA and SiteB). The workflow automatically rolls back to the previous version if a deployment fails, ensuring service continuity.

## Key Features

### 1. **Automatic Version Tracking**
- Before each deployment, the workflow retrieves the currently deployed version
- Stores version information in: `C:\deployments\{ApplicationName}\{Environment}\current-version.txt`
- Tracks deployment history for rollback purposes

### 2. **Self-Healing on Failure**
The workflow automatically detects failures in:
- Deployment process (SCM Remote Command execution)
- Smoke tests validation
- Any critical step in the deployment pipeline

When a failure is detected, the workflow:
1. Identifies the previous stable version
2. Automatically initiates rollback
3. Redeploys the previous version
4. Validates the rollback with smoke tests
5. Notifies about the rollback completion

### 3. **Rollback Process**
The rollback is triggered when:
- Deployment command fails
- Smoke tests fail after deployment
- Any critical deployment step encounters an error

The rollback will:
- Use the same deployment mechanism
- Deploy the previous known-good version
- Run smoke tests to verify service health
- Provide clear notifications about the rollback

## Workflow Steps

### Pre-Deployment
1. **Membership Validation**: Ensures user has proper access rights
2. **Version Retrieval**: Gets currently deployed version for rollback purposes
3. **Environment Setup**: Configures deployment parameters

### Deployment
4. **Artifact Check**: Verifies build artifact availability
5. **Artifact Download**: Downloads if not present on NAS
6. **Remote Deployment**: Executes deployment via SCM command
7. **Smoke Tests**: Validates deployment success
8. **Version Save**: Records successful deployment version

### Self-Healing (on Failure)
9. **Failure Detection**: Monitors deployment and smoke test results
10. **Rollback Initiation**: Triggers if any step fails
11. **Previous Version Deployment**: Redeploys last known-good version
12. **Rollback Validation**: Runs smoke tests on rolled-back version
13. **Notification**: Alerts team about rollback completion

## Usage

### Manual Deployment
1. Go to Actions tab in GitHub repository
2. Select "BPMSClientService-QA-SiteA-SiteB-Deploy" workflow
3. Click "Run workflow"
4. Fill in parameters:
   - **Environment**: Select QA-SiteA or QA-SiteB
   - **Build Version**: Enter version tag (e.g., 1.0, 2.5)
   - **Application Name**: BPMSClientService (default)
5. Click "Run workflow"

### Monitoring
- Watch workflow execution in real-time
- Check deployment logs for each step
- Review rollback notifications if deployment fails

## Version Storage

### File Location
```
C:\deployments\{ApplicationName}\{Environment}\current-version.txt
```

### Example Paths
- QA-SiteA: `C:\deployments\BPMSClientService\QA-SiteA\current-version.txt`
- QA-SiteB: `C:\deployments\BPMSClientService\QA-SiteB\current-version.txt`

### Content Format
The file contains only the version number:
```
1.0
```

## Rollback Behavior

### When Rollback Occurs
- ✅ Deployment command fails
- ✅ Smoke tests fail
- ✅ Any critical step errors out

### When Rollback Does NOT Occur
- ❌ No previous version exists (first deployment)
- ❌ Previous version is "none"
- ❌ Pre-deployment validation fails (before actual deployment)

### Rollback Validation
After rollback, the workflow:
1. Runs the same smoke tests
2. Verifies service is responding correctly
3. Confirms the service is healthy

## Environment Configuration

### Supported Environments
- **QA-SiteA**: First QA site
- **QA-SiteB**: Second QA site

### Environment Variables
Each environment has specific configuration:
- DE Server
- BIAS Service URL
- Application Namespace
- Server List
- Ports

## Security Considerations

### Required Secrets
- `SCM_GITTOKEN`: GitHub token for repository access
- `SCM_USERNAME`: SCM username
- `SCM_PASSWORD`: SCM password
- `NODEAGENT_USERNAME`: Node agent username
- `NODEAGENT_PASSWORD`: Node agent password
- `QASITEASERVERS`: QA SiteA server list
- `QASITEBSERVERS`: QA SiteB server list

### Access Control
- Team membership validation required
- Must be member of: ContentSCM-Admin or 204316_ASR teams

## Troubleshooting

### Deployment Fails and No Rollback
**Possible Causes:**
- First deployment (no previous version)
- Version file not found or corrupted

**Solution:**
- Check if version file exists at expected path
- Verify file permissions
- Review deployment logs

### Rollback Fails
**Possible Causes:**
- Previous version artifact not available
- Network connectivity issues
- SCM server issues

**Solution:**
- Verify previous version exists in artifact repository
- Check network connectivity to SCM server
- Review SCM server logs

### Smoke Tests Fail After Rollback
**Possible Causes:**
- Infrastructure issues
- Database connectivity problems
- Configuration mismatch

**Solution:**
- Check server health manually
- Review application logs
- Verify database connectivity
- Check environment configuration

## Best Practices

### 1. Version Naming
- Use semantic versioning (e.g., 1.0, 1.1, 2.0)
- Avoid special characters
- Keep version numbers short and clear

### 2. Pre-Deployment Checks
- Verify build artifact exists
- Test in lower environment first
- Review recent changes

### 3. Post-Deployment
- Monitor application logs
- Check service health metrics
- Verify functionality manually if needed

### 4. Rollback Scenarios
- Investigate failure before redeploying
- Fix issues in code/configuration
- Test thoroughly in dev/test environments

## Maintenance

### Version File Management
- Automatically managed by workflow
- No manual intervention required
- Backed up with deployment history

### Cleanup
- Workspace cleaned after each run
- Temporary files removed
- No manual cleanup needed

## Future Enhancements

Potential improvements:
- [ ] Keep history of last N deployments
- [ ] Add deployment approval gates
- [ ] Implement canary deployments
- [ ] Add automated health checks
- [ ] Integration with monitoring systems
- [ ] Slack/Teams notifications
- [ ] Deployment metrics dashboard

## Support

For issues or questions:
1. Check workflow logs
2. Review this documentation
3. Contact SCM team
4. Create issue in repository

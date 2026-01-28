# Testing Guide for Self-Healing Deployment Workflow

## Overview
This guide provides step-by-step instructions for testing the self-healing deployment workflow in QA environments.

## Prerequisites

### Required Access
- [ ] Member of ContentSCM-Admin or 204316_ASR team
- [ ] Access to GitHub repository: MaheshTTR/SCM_AI
- [ ] Access to SCM servers and deployment infrastructure
- [ ] Access to QA-SiteA or QA-SiteB servers

### Required Secrets (Verify Configured)
- [ ] `SCM_GITTOKEN`
- [ ] `SCM_USERNAME`
- [ ] `SCM_PASSWORD`
- [ ] `NODEAGENT_USERNAME`
- [ ] `NODEAGENT_PASSWORD`
- [ ] `QASITEASERVERS`
- [ ] `QASITEBSERVERS`

### Test Environment Setup
- [ ] At least one working version deployed (for rollback testing)
- [ ] Build artifacts available for testing (multiple versions)
- [ ] Monitoring/logging access to verify deployments

## Test Scenarios

### Test 1: First Time Deployment (No Previous Version)

**Purpose**: Verify workflow handles first deployment correctly

**Steps**:
1. Ensure no previous deployment exists (or test in fresh environment)
2. Navigate to Actions → BPMSClientService-QA-SiteA-SiteB-Deploy
3. Click "Run workflow"
4. Input parameters:
   - Environment: QA-SiteA
   - Build version: 1.0
   - Application Name: BPMSClientService
5. Click "Run workflow"

**Expected Results**:
- ✅ Workflow starts successfully
- ✅ "Get Current Deployed Version" step shows "No previous version found"
- ✅ Deployment proceeds normally
- ✅ Smoke tests pass
- ✅ Version 1.0 saved to `C:\deployments\BPMSClientService\QA-SiteA\current-version.txt`
- ✅ No rollback triggered
- ✅ Workflow completes successfully

**Validation**:
```powershell
# On the deployment server, verify:
Get-Content "C:\deployments\BPMSClientService\QA-SiteA\current-version.txt"
# Should output: 1.0
```

---

### Test 2: Successful Upgrade Deployment

**Purpose**: Verify normal upgrade path works and version is tracked

**Prerequisites**: Test 1 completed (version 1.0 deployed)

**Steps**:
1. Navigate to Actions → BPMSClientService-QA-SiteA-SiteB-Deploy
2. Click "Run workflow"
3. Input parameters:
   - Environment: QA-SiteA
   - Build version: 2.0
   - Application Name: BPMSClientService
4. Click "Run workflow"

**Expected Results**:
- ✅ Workflow starts successfully
- ✅ "Get Current Deployed Version" step shows "Current deployed version: 1.0"
- ✅ `PREVIOUS_VERSION` set to 1.0
- ✅ `HAS_PREVIOUS` set to true
- ✅ Deployment proceeds normally
- ✅ Smoke tests pass
- ✅ Version 2.0 saved to version file
- ✅ No rollback triggered
- ✅ Workflow completes successfully

**Validation**:
```powershell
# Verify version file updated
Get-Content "C:\deployments\BPMSClientService\QA-SiteA\current-version.txt"
# Should output: 2.0

# Verify application is running version 2.0
# Check application logs or version endpoint
```

---

### Test 3: Failed Deployment with Successful Rollback

**Purpose**: Verify automatic rollback when deployment fails

**Prerequisites**: Test 2 completed (version 2.0 deployed)

**Options to Simulate Failure**:

#### Option A: Use Invalid/Non-existent Version
**Steps**:
1. Navigate to Actions → BPMSClientService-QA-SiteA-SiteB-Deploy
2. Click "Run workflow"
3. Input parameters:
   - Environment: QA-SiteA
   - Build version: 99.99 (non-existent version)
   - Application Name: BPMSClientService
4. Click "Run workflow"

#### Option B: Temporarily Disconnect Server (If Testing Infrastructure Allows)
**Steps**:
1. Temporarily make one or more target servers unreachable
2. Navigate to Actions → BPMSClientService-QA-SiteA-SiteB-Deploy
3. Click "Run workflow"
4. Input valid parameters but deployment will fail due to connectivity

**Expected Results**:
- ✅ Workflow starts successfully
- ✅ "Get Current Deployed Version" step shows "Current deployed version: 2.0"
- ✅ `PREVIOUS_VERSION` set to 2.0
- ✅ `HAS_PREVIOUS` set to true
- ✅ Deployment step fails
- ✅ "Rollback to Previous Version" step triggers
- ✅ Message displays: "DEPLOYMENT FAILED - INITIATING ROLLBACK"
- ✅ Message displays: "Rolling back from version 99.99 to 2.0"
- ✅ "Execute Rollback Deployment" runs with version 2.0
- ✅ "Verify Rollback Success" smoke tests pass
- ✅ "Rollback Notification" displays success message
- ✅ Version file still contains 2.0 (not overwritten with failed version)
- ❌ Workflow overall status: FAILURE (deployment failed)
- ✅ Service remains operational on version 2.0

**Validation**:
```powershell
# Verify version file unchanged
Get-Content "C:\deployments\BPMSClientService\QA-SiteA\current-version.txt"
# Should still output: 2.0

# Verify application is running version 2.0
# Service should be operational and healthy
```

---

### Test 4: Failed Smoke Test with Successful Rollback

**Purpose**: Verify rollback when deployment succeeds but smoke tests fail

**Prerequisites**: Working deployment (e.g., version 2.0)

**Note**: This test requires a version that deploys successfully but fails smoke tests. This might require:
- A specially prepared build artifact with known issues
- Temporarily modifying smoke test expectations
- Coordination with test environment

**Steps**:
1. Prepare a version that will fail smoke tests (consult with dev team)
2. Navigate to Actions → BPMSClientService-QA-SiteA-SiteB-Deploy
3. Click "Run workflow"
4. Input parameters with the problematic version

**Expected Results**:
- ✅ Workflow starts successfully
- ✅ Previous version detected
- ✅ Deployment step succeeds
- ❌ Smoke tests fail
- ✅ Rollback triggers automatically
- ✅ Previous version redeployed
- ✅ Rollback smoke tests pass
- ✅ Success notification displayed
- ✅ Version file unchanged (still shows previous version)
- ✅ Service operational on previous version

---

### Test 5: Environment-Specific Deployment (QA-SiteB)

**Purpose**: Verify workflow works correctly for different environments

**Steps**:
1. Navigate to Actions → BPMSClientService-QA-SiteA-SiteB-Deploy
2. Click "Run workflow"
3. Input parameters:
   - Environment: **QA-SiteB** (different from previous tests)
   - Build version: 1.0
   - Application Name: BPMSClientService
4. Click "Run workflow"

**Expected Results**:
- ✅ Workflow uses QA-SiteB configuration
- ✅ Deploys to QA-SiteB servers (from `QASITEBSERVERS` secret)
- ✅ Separate version file created: `C:\deployments\BPMSClientService\QA-SiteB\current-version.txt`
- ✅ All other features work independently
- ✅ QA-SiteA and QA-SiteB maintain separate version histories

**Validation**:
```powershell
# Verify QA-SiteB version file created
Get-Content "C:\deployments\BPMSClientService\QA-SiteB\current-version.txt"
# Should output: 1.0

# Verify QA-SiteA version file unchanged (if previously tested)
Get-Content "C:\deployments\BPMSClientService\QA-SiteA\current-version.txt"
# Should still show previous version from QA-SiteA tests
```

---

### Test 6: Multiple Sequential Deployments

**Purpose**: Verify version tracking across multiple deployments

**Steps**:
1. Deploy version 1.0 → Success
2. Deploy version 2.0 → Success
3. Deploy version 3.0 → Fail (intentional)
4. Verify rollback to 2.0
5. Deploy version 2.5 → Success
6. Deploy version 3.0 → Success

**Expected Version File History**:
```
After step 1: 1.0
After step 2: 2.0
After step 3: 2.0 (unchanged, failed deployment)
After step 4: 2.0 (rollback confirmed)
After step 5: 2.5
After step 6: 3.0
```

**Validation**:
Track version file contents after each step to ensure correct version persistence.

---

## Verification Checklist

After completing tests, verify:

### Version File Management
- [ ] Version file created on first deployment
- [ ] Version file updated on successful deployments
- [ ] Version file unchanged on failed deployments
- [ ] Separate version files for different environments
- [ ] Version file contains correct format (version only, no extra whitespace)

### Rollback Functionality
- [ ] Rollback triggers only on deployment/smoke test failures
- [ ] Rollback does NOT trigger on pre-deployment failures
- [ ] Rollback uses correct previous version
- [ ] Rollback validation runs smoke tests
- [ ] Rollback notifications display correctly
- [ ] Critical failure alert shown if rollback fails

### Error Handling
- [ ] First deployment handles missing version file gracefully
- [ ] Version save verification catches write failures
- [ ] Rollback handles missing previous version gracefully
- [ ] Clear error messages for all failure scenarios

### Conditional Logic
- [ ] Steps execute in correct order
- [ ] Conditional steps only run when appropriate
- [ ] Always-run steps (cleanup) execute regardless of outcome
- [ ] Step IDs properly track outcomes

## Common Issues and Troubleshooting

### Issue: Version File Not Created
**Symptoms**: Subsequent deployments show "No previous version found"

**Possible Causes**:
- Insufficient permissions on target directory
- Disk space full
- Path incorrect

**Resolution**:
1. Check directory permissions: `C:\deployments\BPMSClientService\{Environment}`
2. Verify disk space
3. Check workflow logs for "Failed to create version file" error
4. Manually create directory with proper permissions if needed

---

### Issue: Rollback Not Triggering
**Symptoms**: Deployment fails but rollback doesn't execute

**Possible Causes**:
- Failure occurred before deployment step
- No previous version exists (first deployment)
- Conditional logic not met

**Resolution**:
1. Check which step failed in workflow logs
2. Verify rollback conditions:
   - `steps.deploy-step.outcome == 'failure'` OR `steps.smoke-test.outcome == 'failure'`
   - `steps.get-current-version.outputs.HAS_PREVIOUS == 'true'`
3. Review step outcomes in workflow summary

---

### Issue: Rollback Fails
**Symptoms**: "CRITICAL: ROLLBACK FAILED" message displayed

**Possible Causes**:
- Previous version artifact no longer available
- SCM server issues
- Network connectivity problems
- Target servers unreachable

**Resolution**:
1. Check if previous version artifact exists in repository
2. Verify SCM server connectivity
3. Check target server status
4. Review rollback deployment logs
5. Perform manual rollback if needed
6. Investigate root cause before next deployment

---

### Issue: Smoke Tests Always Fail
**Symptoms**: Deployments succeed but smoke tests fail, triggering rollback

**Possible Causes**:
- Smoke test configuration incorrect
- Servers not fully started before tests run
- Network/firewall blocking test connections
- Expected patterns don't match actual output

**Resolution**:
1. Review smoke test action configuration
2. Verify server list and ports correct
3. Check if services need more time to start
4. Review smoke test patterns (pattern1: "Clear", pattern2: "QA")
5. Test connectivity manually to verify service reachable

---

## Performance Metrics to Track

During testing, track these metrics:

### Timing
- [ ] Average deployment time (successful)
- [ ] Average rollback time
- [ ] Total workflow duration (deploy + validate)
- [ ] Total workflow duration (deploy fail + rollback + validate)

### Success Rates
- [ ] Deployment success rate
- [ ] Rollback success rate  
- [ ] Smoke test success rate

### Recovery
- [ ] Mean Time to Recovery (MTTR) with rollback
- [ ] Mean Time to Recovery (MTTR) without rollback (historical comparison)

## Post-Testing Actions

After successful testing:

1. **Document Results**
   - [ ] Record test outcomes
   - [ ] Note any issues encountered
   - [ ] Document resolution steps

2. **Update Documentation**
   - [ ] Update DEPLOYMENT.md with lessons learned
   - [ ] Add environment-specific notes if needed
   - [ ] Update troubleshooting section

3. **Team Communication**
   - [ ] Share test results with team
   - [ ] Demonstrate workflow functionality
   - [ ] Provide training on monitoring rollbacks

4. **Production Readiness**
   - [ ] Confirm all tests pass
   - [ ] Verify monitoring/alerting configured
   - [ ] Get approval for production rollout
   - [ ] Plan production deployment schedule

## Emergency Procedures

### If Rollback Fails in Production

1. **Immediate Actions**:
   - Alert on-call team immediately
   - Check service health manually
   - Review workflow logs for error details

2. **Manual Rollback** (if automated rollback fails):
   ```powershell
   # On deployment server:
   
   # 1. Get previous version
   $prevVersion = Get-Content "C:\deployments\BPMSClientService\{Environment}\current-version.txt"
   Write-Host "Previous version: $prevVersion"
   
   # 2. Execute manual deployment using SCM tools
   # (Use same command as workflow, but with previous version)
   
   # 3. Verify service health
   # Check service status and logs
   ```

3. **Post-Incident**:
   - Document incident details
   - Conduct root cause analysis
   - Identify workflow improvements
   - Update runbooks

## Continuous Improvement

Based on testing results, consider:

- [ ] Adjusting smoke test timeouts
- [ ] Adding more comprehensive health checks
- [ ] Implementing notifications (Slack/Teams/Email)
- [ ] Creating deployment dashboard
- [ ] Automating more pre-deployment checks
- [ ] Extending to additional environments

## Approval Sign-off

Testing completed by: ________________  
Date: ________________  
Environment: ________________  

**Test Results Summary**:
- [ ] All test scenarios passed
- [ ] Documentation reviewed and accurate
- [ ] Known issues documented
- [ ] Team trained on workflow
- [ ] Ready for production use

Approved by: ________________  
Date: ________________

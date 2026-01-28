# Self-Healing Deployment Workflow - Quick Reference

## What Was Implemented

### 🎯 Core Self-Healing Features

#### 1. Version Tracking (Before Deployment)
```yaml
- name: Get Current Deployed Version
  id: get-current-version
  shell: pwsh
  continue-on-error: true
  run: |
    $versionFile = "C:\deployments\{App}\{Env}\current-version.txt"
    if (Test-Path $versionFile) {
      $currentVersion = Get-Content $versionFile -Raw
      echo "PREVIOUS_VERSION=$currentVersion" >> $env:GITHUB_OUTPUT
      echo "HAS_PREVIOUS=true" >> $env:GITHUB_OUTPUT
    }
```

#### 2. Save Version (After Success)
```yaml
- name: Save Deployed Version
  if: success()
  shell: pwsh
  run: |
    "{version}" | Set-Content -Path $versionFile -NoNewline
```

#### 3. Automatic Rollback (On Failure)
```yaml
- name: Execute Rollback Deployment
  if: failure() && steps.get-current-version.outputs.HAS_PREVIOUS == 'true'
  uses: tr/ContentSCM_Actions/.github/actions/SCM-RemoteCMDWin@main
  with:
    release: ${{ steps.get-current-version.outputs.PREVIOUS_VERSION }}
```

#### 4. Rollback Validation
```yaml
- name: Verify Rollback Success
  if: failure() && steps.get-current-version.outputs.HAS_PREVIOUS == 'true'
  uses: tr/ContentSCM_Actions/.github/actions/SmokeTest@main
  with:
    build_ver: ${{ steps.get-current-version.outputs.PREVIOUS_VERSION }}
```

## 📊 Workflow Comparison

### Before (Original Workflow)
```
1. Validate membership
2. Setup environment
3. Deploy new version
4. Run smoke tests
5. Clean up
❌ No rollback on failure
❌ Service could be down after failed deployment
```

### After (Self-Healing Workflow)
```
1. Validate membership
2. Get current version (NEW)
3. Setup environment
4. Deploy new version
5. Run smoke tests
   ├─ Success: Save new version (NEW)
   └─ Failure: ↓
6. Detect failure (NEW)
7. Rollback to previous version (NEW)
8. Validate rollback (NEW)
9. Notify rollback success (NEW)
10. Clean up
✅ Automatic rollback on failure
✅ Service restored to working state
```

## 🔄 Self-Healing Flow

### Scenario 1: Successful Deployment
```
Deploy v2.0 → Tests Pass → Save v2.0 → Done ✅
```

### Scenario 2: Failed Deployment with Rollback
```
Deploy v2.0 → Tests Fail → Rollback to v1.5 → Verify v1.5 → Done ✅
```

### Scenario 3: First Deployment (No Rollback)
```
Deploy v1.0 → Tests Fail → No Previous Version → Alert Manual Action ⚠️
```

## 🛡️ Safety Features

### 1. Conditional Rollback
- Only rolls back if previous version exists
- Checks for valid version file
- Handles first deployment gracefully

### 2. Error Handling
- `continue-on-error: true` on version retrieval
- `if: failure()` triggers rollback only on errors
- Multiple condition checks prevent invalid rollbacks

### 3. Validation
- Smoke tests run after deployment
- Smoke tests run after rollback
- Double validation ensures service health

### 4. Notifications
- Clear console messages for rollback events
- Color-coded output (Red for failure, Green for success)
- Detailed information about versions

## 📁 File Structure

```
.github/
├── workflows/
│   └── BPMSClientService-QA-Deploy.yml    (Main workflow)
├── DEPLOYMENT.md                           (User guide)
└── ARCHITECTURE.md                         (Technical docs)

README.md                                   (Updated with links)
```

## 🔧 Configuration Requirements

### Secrets Required
- `SCM_GITTOKEN`
- `SCM_USERNAME`
- `SCM_PASSWORD`
- `NODEAGENT_USERNAME`
- `NODEAGENT_PASSWORD`
- `QASITEASERVERS`
- `QASITEBSERVERS`

### File System Requirements
- Write access to: `C:\deployments\{App}\{Env}\`
- Directory auto-created if doesn't exist

## 💡 Usage Example

### Step-by-Step Deployment

1. **Trigger Workflow**
   - Go to Actions → BPMSClientService-QA-SiteA-SiteB-Deploy
   - Click "Run workflow"
   - Select environment: QA-SiteA
   - Enter version: 2.5
   - Click "Run workflow"

2. **Monitor Execution**
   - Watch each step in real-time
   - Check logs for progress

3. **On Success**
   - Version 2.5 deployed
   - Smoke tests passed
   - Version 2.5 saved for future rollback

4. **On Failure** (Self-Healing Activates)
   - Deployment/tests fail
   - Automatic rollback initiated
   - Previous version (e.g., 2.4) redeployed
   - Rollback validated with tests
   - Service restored to version 2.4
   - Team notified of rollback

## 📈 Benefits

### Reliability
- ✅ Automatic recovery from failures
- ✅ Reduced downtime
- ✅ Consistent deployment process

### Safety
- ✅ Always maintains working state
- ✅ Validated rollback process
- ✅ No manual intervention needed

### Visibility
- ✅ Clear notifications
- ✅ Detailed logs
- ✅ Version tracking

### Efficiency
- ✅ Automated rollback saves time
- ✅ No emergency manual deployments
- ✅ Reduced mean time to recovery (MTTR)

## 🎓 Key Concepts

### Version Persistence
- Version stored on disk, not in workflow variables
- Survives across workflow runs
- Independent per environment

### Idempotent Rollback
- Uses same deployment mechanism
- Consistent behavior
- Reliable results

### Conditional Execution
- Steps run only when appropriate
- Prevents unnecessary operations
- Efficient resource usage

### Fail-Safe Design
- Multiple safety checks
- Graceful handling of edge cases
- Clear error messages

## 📝 Testing Checklist

To verify self-healing works:

- [ ] Deploy version 1.0 (first deployment)
- [ ] Verify version 1.0 saved in version file
- [ ] Deploy version 2.0 successfully
- [ ] Verify version 2.0 saved in version file
- [ ] Deploy version 3.0 (simulate failure)
- [ ] Verify rollback to version 2.0 triggered
- [ ] Verify smoke tests run on version 2.0
- [ ] Verify version file still contains 2.0
- [ ] Check rollback notifications displayed
- [ ] Verify service running on version 2.0

## 🚀 Next Steps

After implementation:
1. Test in QA-SiteA environment first
2. Monitor first few deployments closely
3. Validate version file creation
4. Test rollback scenario (intentional failure)
5. Roll out to QA-SiteB
6. Document any environment-specific issues
7. Consider extending to other environments

# Self-Healing Deployment Workflow Architecture

## Workflow Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    User Triggers Deployment                      │
│              (Environment, Version, Application)                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Validate User Membership                        │
│              (ContentSCM-Admin, 204316_ASR)                      │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│              Get Current Deployed Version                        │
│    Read: C:\deployments\{App}\{Env}\current-version.txt        │
│              Store as PREVIOUS_VERSION                           │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                Set Deployment Configuration                      │
│       (Servers, Ports, BIAS Service, Namespace)                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                  Check Artifact Availability                     │
│          (NAS: scmcontent.int.westgroup.com)                    │
└────────────────────────┬────────────────────────────────────────┘
                         │
                    ┌────┴────┐
                    │ Found?  │
                    └────┬────┘
                         │
          ┌──────────────┴──────────────┐
          │ NO                          │ YES
          ▼                             ▼
┌─────────────────────┐      ┌──────────────────────┐
│ Download Artifact   │      │ Use Existing         │
│ from Repository     │      │ Artifact             │
└──────────┬──────────┘      └──────────┬───────────┘
           │                            │
           └────────────┬───────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────────┐
│                Execute SCM Remote Deployment                     │
│              (deploytomcat with new version)                     │
└────────────────────────┬────────────────────────────────────────┘
                         │
                    ┌────┴────┐
                    │Success? │
                    └────┬────┘
                         │
          ┌──────────────┴──────────────┐
          │ NO                          │ YES
          ▼                             ▼
    ┌─────────┐              ┌──────────────────────┐
    │ FAILURE │              │ Run Smoke Tests      │
    └────┬────┘              └──────────┬───────────┘
         │                              │
         │                         ┌────┴────┐
         │                         │Success? │
         │                         └────┬────┘
         │                              │
         │                   ┌──────────┴──────────┐
         │                   │ NO                  │ YES
         │                   ▼                     ▼
         │              ┌─────────┐    ┌──────────────────────┐
         │              │ FAILURE │    │ Save New Version     │
         │              └────┬────┘    │ as Current           │
         │                   │         └──────────┬───────────┘
         │                   │                    │
         └───────────────────┘                    ▼
                         │              ┌──────────────────────┐
                         │              │ DEPLOYMENT SUCCESS   │
                         │              │ Workflow Complete    │
                         │              └──────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    SELF-HEALING ACTIVATED                        │
│                Check if Previous Version Exists                  │
└────────────────────────┬────────────────────────────────────────┘
                         │
                    ┌────┴────┐
                    │ Exists? │
                    └────┬────┘
                         │
          ┌──────────────┴──────────────┐
          │ NO                          │ YES
          ▼                             ▼
┌─────────────────────┐      ┌──────────────────────────────────┐
│ Report Failure      │      │ Initiate Rollback                │
│ Cannot Rollback     │      │ Display Rollback Message         │
│ (First Deployment)  │      └──────────┬───────────────────────┘
└─────────────────────┘                 │
                                        ▼
                         ┌──────────────────────────────────────┐
                         │ Execute Rollback Deployment          │
                         │ (Deploy PREVIOUS_VERSION)            │
                         └──────────────┬───────────────────────┘
                                        │
                                        ▼
                         ┌──────────────────────────────────────┐
                         │ Verify Rollback with Smoke Tests     │
                         └──────────────┬───────────────────────┘
                                        │
                                   ┌────┴────┐
                                   │Success? │
                                   └────┬────┘
                                        │
                         ┌──────────────┴──────────────┐
                         │ NO                          │ YES
                         ▼                             ▼
              ┌──────────────────────┐    ┌──────────────────────┐
              │ CRITICAL FAILURE     │    │ Display Rollback     │
              │ Manual Intervention  │    │ Success Message      │
              │ Required             │    │ Service Restored     │
              └──────────────────────┘    └──────────┬───────────┘
                                                     │
                                                     ▼
                                          ┌──────────────────────┐
                                          │ ROLLBACK COMPLETE    │
                                          │ Service at Previous  │
                                          │ Stable Version       │
                                          └──────────────────────┘
```

## Component Responsibilities

### 1. Version Tracking Component
- **Purpose**: Track deployed versions for rollback
- **Location**: `C:\deployments\{App}\{Env}\current-version.txt`
- **Actions**: 
  - Read current version before deployment
  - Write new version after successful deployment
  - Provide previous version for rollback

### 2. Deployment Component
- **Purpose**: Execute actual deployment
- **Tool**: SCM-RemoteCMDWin action
- **Actions**:
  - Deploy application to target servers
  - Configure application settings
  - Report deployment status

### 3. Validation Component
- **Purpose**: Verify deployment success
- **Tool**: SmokeTest action
- **Actions**:
  - Test service endpoints
  - Verify application health
  - Report test results

### 4. Self-Healing Component
- **Purpose**: Automatic recovery on failure
- **Trigger**: Any deployment or test failure
- **Actions**:
  - Detect failure state
  - Retrieve previous version
  - Execute rollback deployment
  - Validate rollback success
  - Notify operators

## Decision Points

### 1. Artifact Download Decision
```
Is artifact on NAS?
├─ YES → Use existing artifact
└─ NO → Download from repository
```

### 2. Deployment Success Decision
```
Did deployment succeed?
├─ YES → Proceed to smoke tests
└─ NO → Trigger self-healing
```

### 3. Smoke Test Decision
```
Did smoke tests pass?
├─ YES → Save version, complete successfully
└─ NO → Trigger self-healing
```

### 4. Rollback Eligibility Decision
```
Is there a previous version?
├─ YES → Execute rollback
└─ NO → Report failure (first deployment)
```

### 5. Rollback Validation Decision
```
Did rollback succeed?
├─ YES → Service restored, notify team
└─ NO → Critical failure, manual intervention required
```

## State Transitions

```
Initial State: No Deployment
      ↓
State: Deployment in Progress (Version X)
      ↓
   ┌──┴──┐
   │     │
Success  Failure
   │     │
   │     └─→ State: Rolling Back
   │              ↓
   │         State: Previous Version (Version Y)
   │              ↓
   │         Validated
   │              ↓
   │         State: Service Restored
   │
   └─→ State: Deployed (Version X)
            ↓
       State: Service Running (Version X)
```

## Error Handling Strategy

### Level 1: Automatic Recovery (Self-Healing)
- Deployment failures
- Smoke test failures
- Expected errors

**Action**: Automatic rollback to previous version

### Level 2: Alert and Continue
- Non-critical step failures
- Warnings during deployment
- Recoverable issues

**Action**: Log warning, continue workflow

### Level 3: Manual Intervention Required
- No previous version available
- Rollback failures
- Infrastructure issues

**Action**: Alert team, require manual resolution

## Monitoring Points

1. **Pre-Deployment**: Version retrieval status
2. **Deployment**: Command execution status
3. **Validation**: Smoke test results
4. **Rollback**: Rollback execution status
5. **Post-Rollback**: Service health verification

## Performance Considerations

- Version file read/write: < 1 second
- Deployment time: Depends on application size
- Smoke tests: Configured timeout
- Rollback time: Same as deployment time
- Total self-healing: Deployment time + validation time

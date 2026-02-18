# Add a New Environment

Scaffold a new environment across the application-generator config and directory hierarchy.

## Input

`$ARGUMENTS` should contain the environment name and optionally the environment type.

Examples:
- `staging` — creates a new environment named "staging" (will ask for env type)
- `staging prod` — creates "staging" with envType "prod"
- `test` — creates a new "test" environment

## Steps

### 1. Read Current Environments

Read `charts/application-generator/values.yaml` to understand existing environment definitions. Show the user what currently exists. Note: the `test` environment is currently commented out.

### 2. Gather Configuration

Determine from the user (or arguments):
- **Environment name** (required)
- **Environment type** (`envType`)
- **Is ephemeral** (`isEphemeral`)
- **Promotion source**: direct or from another stage
- **Create PRs** (`asPR`)
- **Branch prefix** (`targetBranchPrefix`): convention is `env/{envName}`

Suggest defaults based on envType:
- `prod`-type: `isEphemeral: false`, `asPR: true`
- `test`-type: `isEphemeral: true`, direct promotions, `asPR: true`

### 3. Update `charts/application-generator/values.yaml`

Add the new environment entry under `envs:`:

```yaml
envs:
  # ... existing envs ...
  {new-env}:
    sources:
      direct: true  # or stages: [...]
    asPR: {true|false}
    isEphemeral: {true|false}
    targetBranchPrefix: env/{new-env}
    envType: {env-type}
```

### 4. Create Config Directories

```
config/envs/{new-env}/
```

If this is a new envType:
```
config/env-types/{new-env-type}/
```

### 5. Optionally Create Application-Level Config Directories

Ask the user if they want per-app environment config directories created.

### 6. Validate

```bash
helm lint charts/application-generator
```

### 7. Summary

Print what was created and remind the user that the `application-generator` will auto-create ArgoCD Applications and Kargo Stages for each app × environment on next sync.

## Important Notes

- Do NOT manually create ArgoCD Application or Kargo Stage manifests.
- Environment names should be lowercase kebab-case.
- The `targetBranchPrefix` convention is `env/{envName}`.
- Existing environment: `prod` (non-ephemeral, direct, `asPR: true`). `test` is commented out.

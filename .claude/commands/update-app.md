# Update an Application Version

Update a specific infrastructure application's Helm chart dependency to a new version.

## Input

`$ARGUMENTS` should contain the application name and optionally a target version.

Examples:
- `argocd` — update to the latest available version
- `cert-manager 1.20.0` — update to a specific version
- `kargo` — update to the latest available version

## Steps

### 1. Identify Target Application

Read `applications/*/Chart.yaml` to find the matching app.

For the app, extract:
- Current `appVersion`
- Current `dependencies[].version`
- `dependencies[].name` (upstream chart name)
- `dependencies[].repository` (registry URL)

### 2. Determine Target Version

If the user provided a specific version, use that.

If not, look up the latest stable version:

**For OCI registries** (`oci://...`):
```bash
helm show chart <oci-url>/<chart-name> 2>&1 | grep -E '^version:'
```

**For HTTPS repositories**:
```bash
helm repo add temp-update <repository-url> 2>/dev/null
helm repo update temp-update 2>/dev/null
helm search repo temp-update/<chart-name> --versions -o json | head -20
helm repo remove temp-update 2>/dev/null
```

Show the user the current vs. target version and confirm before making changes.

### 3. Update Chart.yaml

Update both fields in `applications/{app}/Chart.yaml`:
- `appVersion: "{new-version}"`
- `dependencies[].version: "{new-version}"`

These two values should always match.

### 4. Check for Breaking Changes

If the update is a **major version** change (first number differs), warn the user:
- "This is a major version update. Check the upstream chart's changelog for breaking changes."
- Infrastructure components are critical — major updates can affect the entire cluster.
- Provide the repository/registry URL for reference.

### 5. Validate

```bash
helm lint applications/{app-name}
```

### 6. Summary

Print what was changed:
```
Updated {app-name}:
  appVersion: {old} → {new}
  dependencies[].version: {old} → {new}
```

Remind the user:
- Commit the change to `main` and Kargo will promote through environments
- Infrastructure updates are critical — verify cluster health after promotion

## Important Notes

- Only modify `appVersion` and `dependencies[].version` — do not change `version` (umbrella chart version).
- The `appVersion` and `dependencies[].version` should always be kept in sync.
- Quote the version strings in YAML.
- Skip `kargo-config-infra` and other apps without `dependencies` sections.
- Some charts use OCI registries — these require `helm show chart oci://...` instead of `helm search repo`.

# Add a New Infrastructure Component

Scaffold a new infrastructure application in this repository with all required files and directories.

## Input

The user must provide `$ARGUMENTS` containing at minimum the application name.

Parse the arguments to extract:
- **App name** (required) — kebab-case, e.g., `external-dns`
- **Upstream chart name** — the Helm chart to depend on (if not provided, ask the user)
- **Chart registry/repository URL** — the Helm repo or OCI registry URL (if not provided, ask the user)
- **Chart version** — the version to pin (if not provided, look it up)
- **Namespace** — Kubernetes namespace (if not provided, defaults to app name)

If the arguments are ambiguous or missing required info, ask the user before proceeding.

## Steps

### 1. Look Up the Latest Chart Version (if not provided)

**For OCI registries** (`oci://...`):
```bash
helm show chart <oci-url>/<chart-name> 2>&1 | grep -E '^version:'
```

**For HTTPS repositories**:
```bash
helm repo add temp-scaffold <repository-url> 2>/dev/null
helm repo update temp-scaffold 2>/dev/null
helm search repo temp-scaffold/<chart-name> --versions -o json | head -10
helm repo remove temp-scaffold 2>/dev/null
```

### 2. Create `applications/{app-name}/Chart.yaml`

Follow the exact pattern used by existing apps:

```yaml
apiVersion: v2
name: {app-name}
description: An Umbrella Helm chart for deploying {description}
type: application
version: "0.0.1"
appVersion: "{chart-version}"
dependencies:
  - name: {upstream-chart-name}
    version: "{chart-version}"
    repository: "{registry-url}"
```

Add `namespace: {namespace}` only if it differs from the app name.

### 3. Create `applications/{app-name}/values.yaml`

Create an empty file or with minimal comments.

### 4. Create Config Directory Structure

```
applications/{app-name}/config/
  envs/
    prod/
```

### 5. Create Templates Directory (if needed)

Only create `applications/{app-name}/templates/` if the user mentions needing secrets or custom Kubernetes resources.

### 6. Validate

```bash
helm lint applications/{app-name}
```

### 7. Summary

Print what was created and next steps:
- Adding values overrides in `values.yaml`
- Adding environment-specific config in `config/envs/prod/`
- The application-generator will auto-discover it on next sync

## Important Notes

- Every application MUST have a `Chart.yaml` — this is how auto-discovery works.
- Do NOT create ArgoCD Application or Kargo Stage manifests — the `application-generator` handles that.
- Use `version: "0.0.1"` for the umbrella chart version (convention).
- Quote string values in Chart.yaml.
- Use 2-space indentation.
- Infrastructure components are critical — note any special bootstrap steps needed.

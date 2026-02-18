# Copilot Instructions for homelab-infra

## Repository Context

This is a Kubernetes infrastructure-as-code repository for a home lab. It deploys **core platform services** (ArgoCD, cert-manager, Calico, Kargo, 1Password Connect) using **Helm umbrella charts**, **ArgoCD** (GitOps), and **Kargo** (progressive delivery). There is no application source code here — only deployment configuration for infrastructure components.

## Code Style & Conventions

### YAML
- Use 2-space indentation for all YAML files
- Quote string values in `Chart.yaml` fields (`version: "0.0.1"`)
- Use kebab-case for directory and resource names
- Follow existing Helm template patterns (`{{ .Values.x }}`)

### Naming
- Application dirs: `{component-name}` (e.g., `cert-manager`, `onepassword-connect`)
- ArgoCD resources: `{env}-{app}` (e.g., `prod-argocd`)
- Secrets: `*-credentials.yaml` or `*-secret.yaml` in `templates/`

### Helm Charts
- Every application must have a `Chart.yaml` (auto-discovery depends on this)
- Upstream charts are declared as `dependencies:` in `Chart.yaml`
- Some dependencies use OCI registries (`oci://...`) rather than HTTPS repos
- Default values go in `values.yaml`; environment overrides go in `config/envs/{env}/`
- Use standard Helm template syntax; config files are processed through `config-generator`

## Architecture Rules

- **Do not manually create ArgoCD Application or Kargo Stage manifests** — the `application-generator` chart auto-generates them
- Config hierarchy merges in order: repo global → env-type → env → app global → app env-type → app env (later wins)
- Environments are defined in `charts/application-generator/values.yaml`
- Template variables available in config files: `.Values.envName`, `.Values.envType`, `.Values.appName`
- The `better-tpl` helper enables recursive template rendering (templates referencing other templates)

## When Making Changes

- **All commits MUST be GPG-signed** — never use `--no-gpg-sign` or disable signing. If signing fails, stop and ask the user to fix it.
- Validate with `helm lint` and `helm template` before committing
- Never commit plaintext secrets — use External Secrets Operator with 1Password Connect
- Config in `config/` directories may contain Helm templates — this is intentional
- The `main` branch is the GitOps source of truth
- Promotions use branches like `env/{envName}/{appName}`
- Infrastructure components are critical — changes affect the entire cluster

## File Layout Reference

```
applications/{app}/Chart.yaml      — Metadata + dependency (REQUIRED for auto-discovery)
applications/{app}/values.yaml     — Default overrides
applications/{app}/config/         — Hierarchical config (global/, env-types/, envs/)
applications/{app}/templates/      — K8s secrets, configmaps
charts/application-generator/      — Generates ArgoCD + Kargo resources
charts/config-generator/           — Renders hierarchical config templates
config/                            — Repo-level global/env-type/env configs
bootstrap/                         — One-time cluster setup scripts
```

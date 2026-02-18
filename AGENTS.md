# AI Agent Guide

This file provides context for AI coding agents working in this repository.

## Repository Overview

This is a **Kubernetes infrastructure-as-code** repository for a home lab. It deploys and manages **core platform services and cluster infrastructure** using **Helm charts**, **ArgoCD** (GitOps), and **Kargo** (progressive delivery). The repository does NOT contain application source code — it contains only deployment configuration for infrastructure components.

## Technology Stack

- **Kubernetes** (v1.24+): Container orchestration
- **Helm** (v3.10+): Chart-based Kubernetes package management
- **ArgoCD**: GitOps continuous deployment (syncs Git → cluster)
- **Kargo**: Progressive delivery (staged promotions between environments)
- **cert-manager**: Kubernetes-native TLS certificate management
- **1Password Connect**: Secure secrets integration with 1Password vaults
- **Calico**: Kubernetes networking (CNI) via Tigera Operator
- **YAML**: All configuration is YAML-based

## Key Architecture Concepts

### Umbrella Charts

Each application in `applications/` is an **umbrella Helm chart** — a thin wrapper around an upstream chart (declared as a dependency in `Chart.yaml`). The umbrella chart adds:
- Environment-specific configuration (`config/`)
- Kubernetes secrets and custom resources (`templates/`)
- Override values (`values.yaml`)

### OCI and HTTPS Registries

This repo uses a mix of chart registries:
- **OCI registries**: `oci://ghcr.io/argoproj/argo-helm` (ArgoCD), `oci://ghcr.io/akuity/kargo-charts` (Kargo), `oci://quay.io/jetstack/charts` (cert-manager)
- **HTTPS repos**: `https://docs.tigera.io/calico/charts` (Calico), `https://1password.github.io/connect-helm-charts` (1Password Connect)

### Two Generator Charts

The `charts/` directory contains two critical generator charts:

1. **`application-generator`**: Auto-discovers applications from `applications/*/Chart.yaml` and generates ArgoCD Applications, ApplicationSets, Kargo Stages, and Warehouses for each app × environment combination.

2. **`config-generator`**: Aggregates and renders templated YAML configs from a hierarchical directory structure. It merges configs in priority order (later overrides earlier):
   - Repository global → env-type → environment
   - Application global → env-type → environment

Both generators use a recursive `better-tpl` helper that processes Helm templates within templates.

### Environments

Defined in `charts/application-generator/values.yaml`:
- **prod**: Non-ephemeral, direct promotions, creates PRs (`asPR: true`)
- **test**: Currently commented out — planned as ephemeral with PR-based ApplicationSets

### Configuration Hierarchy

Configuration merges in this order (later wins):
1. `config/global/` — repo-wide defaults
2. `config/env-types/{type}/` — environment-type settings (e.g., prod)
3. `config/envs/{env}/` — environment-specific settings
4. `applications/{app}/config/global/` — app defaults
5. `applications/{app}/config/env-types/{type}/` — app env-type overrides
6. `applications/{app}/config/envs/{env}/` — app environment overrides

### Template Variables

In config YAML files, these Helm template variables are available:
- `.Values.envName` — environment name (e.g., `prod`, `test`)
- `.Values.envType` — environment type (e.g., `prod`, `test`)
- `.Values.appName` — application name (e.g., `argocd`, `cert-manager`)
- Any custom keys from merged config files

### Custom Chart.yaml Fields

Application `Chart.yaml` files use custom fields consumed by the application-generator:
- `namespace`: Target Kubernetes namespace (defaults to app name)
- `releaseName`: Helm release name (defaults to app name)
- `argocd.ignoreDifferences`: Passed through to the generated ArgoCD Application

## Directory Structure

```
applications/              # Umbrella Helm charts (one per infra component)
  argocd/                  # ArgoCD - GitOps CD
  calico/                  # Calico CNI networking (Tigera Operator)
  cert-manager/            # TLS certificate management
  kargo/                   # Progressive delivery platform
  kargo-config-infra/      # Kargo project configuration
  onepassword-connect/     # 1Password secrets integration

bootstrap/                 # One-time cluster setup scripts
  argocd/                  # ArgoCD bootstrap (setup.sh + manifests)
  cert-manager/            # cert-manager bootstrap
  kargo/                   # Kargo bootstrap (setup.sh + manifests)
  onepassword-connect/     # 1Password Connect bootstrap

charts/                    # Reusable Helm chart generators
  application-generator/   # Generates ArgoCD/Kargo resources
  config-generator/        # Renders hierarchical templated configs

config/                    # Repository-level configuration
  global/                  # Applied to all apps and environments
  env-types/               # Per environment-type settings
  envs/                    # Per environment settings

old/                       # Deprecated/archived configurations
```

## Conventions & Patterns

### Naming
- Application directories use kebab-case: `cert-manager`, `onepassword-connect`
- Generated ArgoCD resource names follow `{env}-{app}` pattern (e.g., `prod-argocd`)
- Kargo project name: `homelab-infra`

### File Patterns
- Secrets go in `templates/*-credentials.yaml` or `templates/*-secret.yaml`
- Config files use standard Helm template syntax (`{{ .Values.x }}`)
- All YAML files in `config/` directories may contain Helm templates

### Chart Structure
- Every application MUST have a `Chart.yaml` (this is how auto-discovery works)
- `values.yaml` contains default overrides for the upstream chart
- Dependencies are declared in `Chart.yaml` under `dependencies:`
- Some charts use OCI registries (`oci://...`) instead of HTTPS repos

### Git Workflow
- `main` branch is the source of truth
- Kargo promotes changes via branches prefixed with `env/{envName}/{appName}`
- Prod promotions create PRs for review (`asPR: true`)
- **All commits MUST be GPG-signed.** Never use `--no-gpg-sign`, `-c commit.gpgsign=false`, or any other mechanism to bypass commit signing. If signing fails (e.g., 1Password agent not running), stop and ask the user to fix it — do not work around it.

## Common Tasks

### Adding a New Infrastructure Component
1. Create `applications/{app-name}/Chart.yaml` with upstream dependency
2. Create `applications/{app-name}/values.yaml` with default overrides
3. Add environment configs in `applications/{app-name}/config/envs/{env}/`
4. Add templates/secrets in `applications/{app-name}/templates/` if needed
5. The application-generator will auto-discover it from `Chart.yaml`

### Updating a Component Version
1. Edit `dependencies[].version` in `applications/{app}/Chart.yaml`
2. Update `appVersion` in `Chart.yaml` to match
3. Commit and let Kargo promote through environments

### Validating Changes
```bash
# Lint a chart
helm lint applications/{app-name}

# Render templates locally
helm template applications/{app-name}
```

## Important Warnings

- **All commits MUST be GPG-signed.** Never bypass or disable commit signing under any circumstances. If signing fails, stop and ask the user to resolve the issue.
- **Never commit secrets in plaintext** — use External Secrets Operator with 1Password Connect
- **Do not manually create ArgoCD Application or Kargo Stage manifests** — the `application-generator` chart auto-generates them
- **Do not manually edit generated manifests** — they are produced by the generator pipeline
- The `config-generator` paths reference `config/platform/` and `config/application/` — these are mapped during the Kargo promotion process
- Helm template syntax in YAML config files is intentional and processed by `config-generator`
- The `better-tpl` helper recursively renders templates, so templated values can reference other templated values
- Infrastructure components are **critical** — ArgoCD and cert-manager outages affect the entire cluster

## Reference Documentation

- [README.md](README.md) — Full project documentation

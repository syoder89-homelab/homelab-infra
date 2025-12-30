# homelab-infra

A Kubernetes-based infrastructure-as-code repository for deploying and managing core platform services and cluster infrastructure using Helm charts, ArgoCD, and Kargo. This project provides umbrella Helm charts and configurations for critical infrastructure components across different environments.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Infrastructure Applications](#infrastructure-applications)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Deployment](#deployment)
- [Development](#development)
- [Contributing](#contributing)

## Overview

This repository manages the core infrastructure and platform services for a Kubernetes cluster with:

- **Core Infrastructure**: ArgoCD (GitOps CD), cert-manager (certificate management), Kargo (progressive delivery), and 1Password Connect (secrets integration)
- **Multiple Environments**: Support for different deployment environments (prod, test, dev)
- **GitOps Workflow**: Integration with ArgoCD for continuous deployment and Kargo for progressive delivery
- **Helm-based Deployment**: Umbrella charts for easy infrastructure component management
- **Bootstrap Automation**: Automated setup and initialization of critical cluster services

## Architecture

### Technology Stack

- **Kubernetes**: Container orchestration platform
- **Helm**: Package manager for Kubernetes applications
- **ArgoCD**: GitOps continuous deployment tool
- **Kargo**: Progressive delivery platform for safer infrastructure deployments
- **cert-manager**: Kubernetes native certificate management
- **1Password Connect**: Secure secrets integration with 1Password vaults
- **YAML-based Configuration**: Version-controlled infrastructure definitions

### Components

```
homelab-infra/
├── bootstrap/          # Initial cluster setup and bootstrapping for infrastructure services
├── applications/       # Infrastructure component definitions (umbrella charts)
├── charts/            # Helm chart generators
├── config/            # Global and environment-specific configurations
└── README.md          # This file
```

## Project Structure

### `bootstrap/`

Contains initialization scripts and manifests for setting up the Kubernetes cluster infrastructure:

- **`argocd/`**: ArgoCD setup for GitOps deployments
  - `setup.sh`: Script to initialize ArgoCD and deploy core infrastructure applications
  - `manifests/`: ArgoCD Application and AppProject definitions for infrastructure components
  
- **`cert-manager/`**: Certificate manager setup for TLS certificate management
  - `setup.sh`: Script to initialize cert-manager
  - `manifests/`: cert-manager Application definitions and issuers

- **`kargo/`**: Kargo setup for progressive infrastructure deployments
  - `setup.sh`: Script to initialize Kargo
  - `manifests/`: Kargo Project, Stages, Tasks, and Warehouse definitions for infrastructure promotions

- **`onepassword-connect/`**: 1Password Connect setup for secret management integration
  - `setup.sh`: Script to initialize 1Password Connect operator
  - `manifests/`: Secret Operator Application definitions

### `applications/`

Umbrella Helm charts for core infrastructure services:

- `argocd/`: ArgoCD - GitOps continuous deployment tool
  - Manages declarative Kubernetes resource synchronization
  - Enables GitOps workflows for all cluster applications

- `cert-manager/`: Certificate management and TLS automation
  - Automates SSL/TLS certificate provisioning and renewal
  - Supports Let's Encrypt and other certificate authorities

- `kargo/`: Progressive delivery platform
  - Enables safe, automated promotion workflows between environments
  - Manages staged rollouts and approval gates

- `kargo-config-infra/`: Kargo configuration specific to infrastructure deployments
  - Defines promotion stages and workflow for infrastructure components

- `onepassword-connect/`: 1Password Connect integration
  - Enables secure secret management from 1Password vaults
  - Provides ExternalSecrets integration

Each application follows the structure:
```
application-name/
├── Chart.yaml              # Helm chart metadata
├── values.yaml             # Default Helm values
├── charts/                 # Dependent chart repositories
├── config/
│   ├── env-types/          # Application-specific environment type configs (optional)
│   ├── envs/               # Environment-specific configurations
│   └── global/             # Application-level global configurations
├── templates/              # Kubernetes manifests and secrets
└── files/                  # Static configuration files
```

### `charts/`

Helm chart generators and utilities:

- **`application-generator/`**: Generates ArgoCD Applications from chart definitions
- **`config-generator/`**: Generates configuration and values templates

### `config/`

Global and environment-specific configuration:

- **`env-types/`**: Environment type definitions (e.g., `prod/` for production-type settings)
- **`global/`**: Repository-wide global settings
- **`envs/`**: Environment configurations (e.g., `prod/`, `test/`)

## Infrastructure Applications

| Application | Purpose | Critical |
|---|---|---|
| **ArgoCD** | GitOps continuous deployment and synchronization | Yes |
| **cert-manager** | Kubernetes-native certificate management and TLS automation | Yes |
| **Kargo** | Progressive delivery and safe promotion workflows | No |
| **Kargo Config (Infra)** | Infrastructure-specific Kargo configuration | No |
| **1Password Connect** | Secure secrets integration with 1Password vaults | No |

## Getting Started

### Prerequisites

- Kubernetes cluster (v1.24+)
- `kubectl` configured to access your cluster
- `helm` CLI (v3.10+)
- Git access to this repository
- 1Password account with Connect token (optional, for secrets management)

### Initial Cluster Setup

Follow these steps in order to bootstrap the infrastructure:

1. **Bootstrap ArgoCD** (required - enables GitOps):
   ```bash
   cd bootstrap/argocd
   ./setup.sh
   ```

2. **Bootstrap cert-manager** (recommended for TLS):
   ```bash
   cd bootstrap/cert-manager
   ./setup.sh
   ```

3. **Bootstrap Kargo** (optional, for progressive delivery):
   ```bash
   cd bootstrap/kargo
   ./setup.sh
   ```

4. **Bootstrap 1Password Connect** (optional, for secrets integration):
   ```bash
   cd bootstrap/onepassword-connect
   ./setup.sh
   ```

5. **Verify deployments**:
   ```bash
   kubectl get all -A
   kubectl get applications -A  # ArgoCD Applications
   ```

## Configuration

### Repository-Level vs Application-Level Configuration

The configuration hierarchy is divided into two levels, each serving a specific purpose:

**Repository-Level Configuration** (`config/`):
- Provides common configurations shared across all infrastructure applications
- Use cases: common labels, tags, monitoring configurations, global policies
- Structure: `env-types/`, `global/`, `envs/`
- Applied to every application in the repository

**Application-Level Configuration** (`applications/[app-name]/config/`):
- Provides application-specific overrides and customizations
- Use cases: application-specific settings, TLS configuration, secret references
- Structure: `env-types/` (optional), `global/`, `envs/`
- Applied only to the specific application

### Environments and Kargo Stages

Configurations are organized by **environment type** (e.g., `prod`, `dev`, `test`) and **environment** (specific deployments). For each environment, a corresponding Kargo stage is created for every application, enabling progressive delivery and promotion workflows.

The configuration hierarchy follows this order (later overrides earlier):
1. **Repository-level `global/`**: Shared settings for all apps and all environments
2. **Repository-level `env-types/[type]/`**: Shared settings for a specific environment type
3. **Repository-level `envs/[env]/`**: Shared settings for a specific environment
4. **Application-level `global/`**: Application-specific settings for all environments
5. **Application-level `env-types/[type]/`** (optional): Application-specific overrides for a specific environment type
6. **Application-level `envs/[env]/`** (optional): Application-specific overrides for a specific environment

For example, with a production environment and an ephemeral test environment:

```
Repository level (shared across all apps):
config/
├── env-types/
│   └── prod/                 # Prod env-type: common labels, tags, policies
├── global/                   # Global: repository-wide settings
└── envs/
    └── prod/                 # Prod env: production-specific shared configs

Application level (app-specific overrides):
applications/argocd/config/
├── env-types/
│   ├── prod/                 # ArgoCD-specific prod settings
│   └── test/                 # ArgoCD-specific test settings
├── global/                   # ArgoCD-specific global settings
└── envs/
    └── prod/                 # ArgoCD-specific prod environment settings
```

### Ephemeral Environments

Environments can be marked as ephemeral using the `isEphemeral` flag in the environment configuration. Ephemeral environments have different deployment behavior—they are temporary environments typically created from pull requests or short-lived test branches. The `test` environment is currently configured as ephemeral and creates temporary Kargo stages for testing before merging to main.

### Application Configuration

Each application supports multiple configuration levels:

1. **Default Values** (`values.yaml`): Base configuration
2. **Global Config** (`config/global/*.yaml`): Applied to all environments
3. **Environment Config** (`config/envs/[env-name]/*.yaml`): Environment-specific overrides
4. **Templates** (`templates/*.yaml`): Kubernetes manifests and secrets

### Configuration Templating

Configuration files support Helm templating, allowing you to use variables, conditionals, and other Helm functions. This enables dynamic configuration based on the environment, environment type, or other values.

**Template Syntax**: Use standard Helm template syntax in YAML files:
```yaml
# Example: Using environment and environment type variables
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.appName }}-config
  namespace: {{ .Values.namespace }}
spec:
  config.yaml: |
    environment: {{ .Values.envName }}
    environment_type: {{ .Values.envType }}
    {{- if eq .Values.envType "prod" }}
    replicas: 3
    {{- else }}
    replicas: 1
    {{- end }}
```

**Available Template Variables**:
- `.Values.envName`: Name of the current environment (e.g., `prod`, `test`)
- `.Values.envType`: Type of the current environment (e.g., `prod`, `test`)
- Any other values defined in your configuration files (merged hierarchically)

The `config-generator` chart processes all configuration files through Helm's templating engine, allowing for flexible, dynamic configurations across your environments.

### Adding Custom Values

To customize an infrastructure application:

1. **For repository-wide settings** (apply to all apps):
   - Edit `config/global/` for settings shared by all apps
   - Edit `config/env-types/[type]/` for environment-type-wide settings
   - Edit `config/envs/[env]/` for environment-specific shared settings

2. **For application-specific settings**:
   - Edit `applications/[app-name]/values.yaml` for application defaults
   - Add settings in `applications/[app-name]/config/global/` for app-wide overrides
   - Add settings in `applications/[app-name]/config/env-types/[type]/` for app-specific environment type overrides
   - Add settings in `applications/[app-name]/config/envs/[env]/` for app-specific environment overrides

3. **Deploy changes**:
   - Use Kargo to gradually roll out changes across environments
   - Review the configuration cascade to understand which settings will take precedence

## Deployment

Deployments are GitOps-driven using ArgoCD and Kargo. Changes are automatically deployed from Git, and promotions between environments are managed through Kargo stages.

### ArgoCD Sync

ArgoCD automatically syncs the desired state from Git to the cluster. To trigger a manual sync:

```bash
argocd app sync [app-name]
```

### Kargo Promotions

Infrastructure changes are promoted through environments using Kargo stages:

```bash
# View promotion status
kubectl get promotions -n kargo

# Approve a promotion
kubectl patch promotion [promotion-name] -n kargo -p '{"status":{"approvalSignal":"approved"}}'
```

## Development

### Adding a New Infrastructure Component

1. **Create application directory**:
   ```bash
   mkdir -p applications/new-component/{config,templates,charts}
   ```

2. **Create Chart.yaml**:
   ```yaml
   apiVersion: v2
   name: new-component
   description: An Umbrella Helm chart for deploying [Component Name]
   type: application
   version: "0.0.1"
   appVersion: "1.0.0"
   dependencies:
     - name: component-chart
       version: "1.0.0"
       repository: "oci://[registry]"
   ```

3. **Create values.yaml** with default values

4. **Add configuration templates** in `templates/`

5. **Define environment-specific configs** in `config/envs/[env-name]/`

### Updating Infrastructure Versions

To update a component version:

1. Edit the `dependencies` section in `Chart.yaml`
2. Run `helm dependency update` in the application directory
3. Test changes in a staging environment
4. Use Kargo to promote to production

### Secrets Management

Sensitive data (API keys, passwords, credentials, 1Password tokens) are stored in:
- `templates/*-credentials.yaml`
- `templates/*-secret.yaml`
- `config/envs/[env-name]/*-secret.yaml`

For 1Password integration:
- Use `ExternalSecrets` Operator with `SecretStore` pointing to 1Password Connect
- Reference secrets stored in 1Password vaults through `ExternalSecret` resources

These should be managed with appropriate secret management tools (e.g., External Secrets Operator with 1Password, Sealed Secrets).

## Contributing

### Guidelines

- Follow the existing directory structure and naming conventions
- Update documentation when making infrastructure changes
- Test changes in staging before promoting to production
- Use Kargo for staged, progressive rollouts of infrastructure updates
- Keep secrets out of Git (use secret management tools)
- Ensure infrastructure components maintain high availability

### Making Changes

1. Create a feature branch
2. Make changes to infrastructure component configs or charts
3. Test with `helm lint` and `helm template`
4. Submit a pull request
5. ArgoCD will automatically sync approved changes

## Troubleshooting

### Check Application Status

```bash
# View application health
kubectl get all -n [namespace]

# Check pod logs
kubectl logs -n [namespace] deployment/[deployment-name]

# Describe resources
kubectl describe deployment [deployment-name] -n [namespace]
```

### View ArgoCD Details

```bash
# Port-forward to ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Check application status
argocd app list

# Check sync status
kubectl get applications -A
```

### Verify Kargo Promotions

```bash
# Watch stage status
kubectl get stages -n kargo -w

# Check promotion status
kubectl get promotions -n kargo

# View promotion details
kubectl describe promotion [promotion-name] -n kargo
```

### Verify cert-manager

```bash
# Check cert-manager deployment
kubectl get deployment -n cert-manager

# List certificates
kubectl get certificate -A

# Check certificate details
kubectl describe certificate [cert-name] -n [namespace]
```

### Verify 1Password Connect (if deployed)

```bash
# Check 1Password Connect deployment
kubectl get deployment -n onepassword-connect

# Check ExternalSecrets
kubectl get externalsecrets -A

# View secret operator events
kubectl logs -n onepassword-connect deployment/onepassword-connect
```

## Directory Reference

| Path | Purpose |
|------|---------|
| `applications/` | Infrastructure component umbrella charts and configurations |
| `bootstrap/` | Initial cluster infrastructure setup scripts and manifests |
| `charts/` | Reusable Helm chart generators |
| `config/` | Global and environment-specific infrastructure settings |
| `old/` | Deprecated or archived configurations |
| `.gitignore` | Git ignore rules (secrets, temporary files) |
| `README.md` | This documentation |


---

**Last Updated**: December 2025
**Kubernetes Version**: v1.24+
**Helm Version**: v3.10+

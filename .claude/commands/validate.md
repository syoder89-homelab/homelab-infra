# Validate Charts

Lint and template-render Helm charts to catch errors before committing.

## Input

`$ARGUMENTS` is optional:
- If provided, validate only the specified application(s) (e.g., `argocd`)
- If empty, validate ALL applications and generator charts

## Steps

### 1. Determine Scope

If `$ARGUMENTS` is provided, validate only matching apps under `applications/`.
If empty, collect all directories that contain a `Chart.yaml`:
- `applications/*/Chart.yaml`
- `charts/application-generator/Chart.yaml`
- `charts/config-generator/Chart.yaml`

### 2. Lint Each Chart

For each chart, run:
```bash
helm lint <chart-path> 2>&1
```

Track pass/fail. Lint warnings about missing dependencies are expected for umbrella charts.

### 3. Template Render (applications only)

For each application chart, attempt:
```bash
helm template <app-name> <chart-path> 2>&1
```

Template render failures due to missing chart dependencies are expected — note but don't count as errors.

### 4. Check for Common Issues

Scan application YAML files for:
- **Unquoted version strings** in `Chart.yaml`
- **Missing `Chart.yaml`** in any `applications/*/` directory
- **Mismatched versions**: `appVersion` not matching `dependencies[].version`

### 5. Report Results

```
# Validation Report — <date>

## Results
✓ <app-name>: lint passed, template passed
✓ <app-name>: lint passed, template skipped (missing deps)
✗ <app-name>: lint failed — <error summary>

## Summary
- X charts validated
- Y passed
- Z failed
- N warnings

## Issues Found
(list any issues from step 4)
```

## Important Notes

- Lint warnings about missing dependency charts are normal — deps are resolved during Kargo promotion.
- Template failures from missing subcharts are expected for umbrella charts.
- Generator charts should lint cleanly since they have no external dependencies.

# Check for Application Updates

Check all infrastructure applications in this repository for available Helm chart version updates and produce an update report.

## Instructions

1. **Read every `applications/*/Chart.yaml`** file and extract the current `appVersion` and `dependencies[].version`, `dependencies[].name`, and `dependencies[].repository` for each application.

2. **Skip applications that don't have upstream dependencies** (e.g., `kargo-config-infra` has no `dependencies` section — it is a config-only chart).

3. **For each application with a dependency**, determine the registry type and look up the latest version:

   **For OCI registries** (`oci://...`):
   ```bash
   helm show chart <oci-url>/<chart-name> 2>&1 | grep -E '^version:|^appVersion:'
   ```
   Or to get multiple versions:
   ```bash
   helm search repo <chart-name> --versions -o json 2>/dev/null | head -50
   ```
   Note: OCI charts may need to be pulled first. If `helm show chart` works, use it. Otherwise try:
   ```bash
   helm pull <oci-url>/<chart-name> --version <version> --untar --untardir /tmp/update-check 2>&1
   ```

   **For HTTPS repositories**:
   ```bash
   helm repo add <temp-name> <repository-url> 2>/dev/null; helm repo update <temp-name> 2>/dev/null
   helm search repo <temp-name>/<chart-name> --versions -o json 2>/dev/null | head -50
   helm repo remove <temp-name> 2>/dev/null
   ```

4. **Compare the current pinned version** in `Chart.yaml` against the latest available version. Classify each result:
   - **Up to date**: current version matches latest
   - **Patch update**: only patch version differs (e.g., `1.19.0` → `1.19.1`)
   - **Minor update**: minor version differs (e.g., `8.5.0` → `9.0.6`)
   - **Major update**: major version differs (e.g., `1.x` → `2.x`)

5. **Produce a summary report** printed to stdout in this markdown format:

   ```
   # Infrastructure Update Check — <today's date>

   ## Summary
   - X applications checked
   - Y updates available (N major, N minor, N patch)
   - Z applications up to date
   - N applications skipped (no dependency)

   ## Updates Available

   ### <App Name> — <severity emoji> <Major/Minor/Patch> Update
   - **Chart**: <dependency chart name>
   - **Current Version**: <version>
   - **Latest Version**: <version>
   - **Registry**: <url>

   ## Up to Date
   - <app>: <version>

   ## Skipped
   - <app>: <reason>
   ```

   Use these severity emojis: 🔴 Major, 🟡 Minor, 🟢 Patch.

6. **Clean up** any temporary helm repos added during the check.

7. **If the user provided the argument `$ARGUMENTS`**, treat it as a filter — only check the application(s) matching that name. If no argument is provided, check all applications.

## Important Notes

- Do NOT modify any files — this is a read-only check.
- Chart versions use exact pins (no semver ranges). The `dependencies[].version` and `appVersion` should always match.
- The `version` field in `Chart.yaml` is the umbrella chart version — ignore it for update checking.
- If a registry query fails or returns no results, note it as "Unable to check" rather than failing the entire report.
- Infrastructure components are critical — always note when major version updates are available as they may have breaking changes.
- Some charts use OCI registries (`oci://ghcr.io/...`, `oci://quay.io/...`) which require different lookup commands than HTTPS repos.

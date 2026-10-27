# Security notes

The custom payment workload is the security boundary maintained by this fork. Its container runs as a numeric non-root user, disables privilege escalation, drops Linux capabilities, uses a read-only root filesystem in Kubernetes, pins Python dependencies, and is blocked by CI on high or critical image findings.

The remaining Robot Shop containers are archived demonstration images from the upstream project. Several run as root and require writable filesystems, so applying a blanket restricted security context would prevent them from starting. They should not be treated as production images. Rebuilding each service on supported runtimes with explicit non-root users is a future hardening task outside the observability capstone.

The observability manifests and payment source are scanned independently so inherited legacy findings do not conceal regressions in code maintained by this fork.

The `.trivyignore` entries are narrowly scoped false-positive exceptions from the official Python base image's attached third-party SBOM. They are documented in `docs/architecture.md` and must be revalidated whenever the base image digest changes.

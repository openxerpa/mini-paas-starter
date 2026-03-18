# DEPLOY_REGISTRY_TOKEN Setup

This guide explains how to create and configure `DEPLOY_REGISTRY_TOKEN`, the GitHub Personal Access Token (PAT) used by the deploy target server to pull container images from GitHub Container Registry (ghcr.io).

## Overview

During CI/CD, the **build-and-push** job runs on a GitHub Actions runner and pushes images to ghcr.io using `GITHUB_TOKEN` (automatically provided). The **deploy** job, however, runs Ansible on your deploy target server—a separate machine that has no access to `GITHUB_TOKEN`. That server must authenticate to ghcr.io before it can `docker pull` private images. `DEPLOY_REGISTRY_TOKEN` is the credential passed to Ansible for that purpose.

| Operation | Where it runs | Credential used |
|-----------|---------------|------------------|
| Push image | GitHub Actions runner | `GITHUB_TOKEN` (automatic) |
| Pull image | Deploy target server | `DEPLOY_REGISTRY_TOKEN` (you configure) |

## When You Need It

- **Private ghcr.io images** — Required. The deploy playbook will fail if the token is missing when pulling from ghcr.io.
- **Public ghcr.io images** — Optional. The playbook skips `docker login` when the token is empty; public images can be pulled without authentication.

## Creating the Token

GitHub Packages (including ghcr.io) only supports **classic** Personal Access Tokens. Fine-grained tokens do not support Packages access.

### Steps

1. Sign in to GitHub and go to your **personal account** (not the organization).
2. **Settings** → scroll to **Developer settings** (bottom of left sidebar).
3. **Personal access tokens** → **Tokens (classic)**.
4. **Generate new token (classic)**.
5. Set a note (e.g. `deploy-registry-ghcr.io`), choose an expiration, and select:
   - **`read:packages`** — Download container images and read metadata.
6. If your organization uses SSO, click **Configure SSO** and authorize the token for the org.
7. **Generate token** and copy it. Store it securely; you cannot view it again.

### Token Type: Classic vs Fine-grained

| Type | Packages support |
|------|------------------|
| **Tokens (classic)** | Yes — use this for `DEPLOY_REGISTRY_TOKEN` |
| **Fine-grained tokens** | No — GitHub Packages is not available |

## Configuring in GitHub

Add the token as a secret so your workflows can use it.

### Repository-level

1. Open the repository → **Settings** → **Secrets and variables** → **Actions**.
2. **New repository secret**.
3. Name: `DEPLOY_REGISTRY_TOKEN`, Value: paste the token.

### Organization-level

1. Open the organization → **Settings** → **Secrets and variables** → **Actions**.
2. **New organization secret**.
3. Name: `DEPLOY_REGISTRY_TOKEN`, Value: paste the token.
4. **Repository access**: All repositories, or select specific repos.

Org-level secrets are shared across repos. The token itself is still created under a personal account; the org stores it and makes it available to workflows.

## FAQ

**Why doesn’t CI push need this token?**  
The build-and-push job runs on a GitHub Actions runner and uses `GITHUB_TOKEN`, which GitHub injects automatically. That token has `packages: write` for the workflow repository, so it can push without any extra secret.

**Why can’t I use a Fine-grained token?**  
GitHub Packages (ghcr.io) does not support Fine-grained tokens. You must use a classic PAT with `read:packages`.

**Can the organization create the token?**  
Tokens are always created by a user. An org admin (or someone with package access) creates the classic PAT from their account, then adds it as an organization secret so all org repos can use it.

## References

- [Working with the Container registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Managing personal access tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

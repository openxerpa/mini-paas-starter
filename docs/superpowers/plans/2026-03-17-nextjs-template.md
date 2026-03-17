# Next.js Template Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `nextjs-service` cookiecutter template with Next.js 15 App Router, TypeScript, Tailwind, Standalone output, multi-stage Dockerfile, .dockerignore, and non-root distroless runtime—aligned with existing node-service CI/CD and deploy patterns.

**Architecture:** New template at `templates/nextjs-service/` alongside go-service, node-service, python-service. Copy and adapt node-service workflows (ci-cd, emergency-deploy, deploy) and configs (docker-compose, .env.example, README). Next.js-specific: standalone build, three-stage Dockerfile, .dockerignore.

**Tech Stack:** Next.js 15, TypeScript, Tailwind CSS, pnpm 10, Node 24, distroless nodejs24-debian13:nonroot.

**Spec:** `docs/superpowers/specs/2026-03-17-nextjs-template-design.md`

---

## File Structure

| Path | Responsibility |
|------|----------------|
| `templates/nextjs-service/cookiecutter.json` | Template variables (same as node-service) |
| `templates/nextjs-service/hooks/pre_gen_project.py` | Validate project_slug |
| `templates/nextjs-service/{{cookiecutter.project_slug}}/app/*` | Next.js App Router pages and layout |
| `templates/nextjs-service/{{cookiecutter.project_slug}}/next.config.ts` | output: 'standalone' |
| `templates/nextjs-service/{{cookiecutter.project_slug}}/package.json` | Dependencies, scripts (dev, build, start, test) |
| `templates/nextjs-service/{{cookiecutter.project_slug}}/Dockerfile` | Multi-stage build |
| `templates/nextjs-service/{{cookiecutter.project_slug}}/.dockerignore` | Build context exclusions |
| `templates/nextjs-service/{{cookiecutter.project_slug}}/.github/workflows/*` | CI/CD, emergency deploy |
| `templates/nextjs-service/{{cookiecutter.project_slug}}/.github/deploy.yml` | Ansible playbook |

---

## Chunk 1: Cookiecutter and Next.js Scaffold

### Task 1: Create cookiecutter structure

**Files:**
- Create: `templates/nextjs-service/cookiecutter.json`
- Create: `templates/nextjs-service/hooks/pre_gen_project.py`

- [ ] **Step 1: Create cookiecutter.json**

Copy from `templates/node-service/cookiecutter.json` (identical variables).

```json
{
  "project_name": "My Service",
  "project_slug": "{{ cookiecutter.project_name|lower|replace(' ', '-') }}",
  "description": "A short description of the service",
  "github_org": "your-org",
  "service_type": ["external", "internal"],
  "service_port": "3000",
  "docker_registry": "ghcr.io",
  "base_domain_dev": "a.com",
  "base_domain_test": "a.com",
  "base_domain_prod": "c.com",
  "memory_limit": "512M"
}
```

- [ ] **Step 2: Create pre_gen_project.py**

Copy from `templates/node-service/hooks/pre_gen_project.py` (identical).

```python
import re
import sys

SLUG_RE = re.compile(r"^[a-z][a-z0-9]*(-[a-z0-9]+)*$")

slug = "{{ cookiecutter.project_slug }}"

if not SLUG_RE.match(slug):
    print(
        f"ERROR: Invalid project_slug '{slug}'.\n"
        "       Must be lowercase letters, digits, and hyphens only.\n"
        "       Must start with a letter. No spaces, uppercase, or trailing hyphens.\n"
        "       Examples: my-service, api-v2, backend"
    )
    sys.exit(1)
```

- [ ] **Step 3: Commit**

```bash
git add templates/nextjs-service/cookiecutter.json templates/nextjs-service/hooks/pre_gen_project.py
git commit -m "feat(nextjs-template): add cookiecutter config and pre_gen hook"
```

---

### Task 2: Create Next.js app files

**Files:**
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/app/layout.tsx`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/app/page.tsx`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/app/globals.css`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/next.config.ts`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/tailwind.config.ts`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/postcss.config.mjs`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/tsconfig.json`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/public/.gitkeep`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/next-env.d.ts`

- [ ] **Step 1: Create app/layout.tsx**

```tsx
import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "{{ cookiecutter.project_name }}",
  description: "{{ cookiecutter.description }}",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
```

- [ ] **Step 2: Create app/page.tsx**

```tsx
export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold">{{ cookiecutter.project_name }}</h1>
      <p className="mt-4 text-gray-600">{{ cookiecutter.description }}</p>
    </main>
  );
}
```

- [ ] **Step 3: Create app/globals.css**

```css
@tailwind base;
@tailwind components;
@tailwind utilities;
```

- [ ] **Step 4: Create next.config.ts**

```ts
import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  output: "standalone",
};

export default nextConfig;
```

- [ ] **Step 5: Create tailwind.config.ts**

```ts
import type { Config } from "tailwindcss";

export default {
  content: [
    "./pages/**/*.{js,ts,jsx,tsx,mdx}",
    "./components/**/*.{js,ts,jsx,tsx,mdx}",
    "./app/**/*.{js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
} satisfies Config;
```

- [ ] **Step 6: Create postcss.config.mjs**

```javascript
/** @type {import('postcss-load-config').Config} */
const config = {
  plugins: {
    tailwindcss: {},
  },
};

export default config;
```

- [ ] **Step 7: Create tsconfig.json**

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

- [ ] **Step 8: Create public/.gitkeep**

Empty file (or `# keep`). Ensures `public/` exists for Docker COPY.

- [ ] **Step 9: Create next-env.d.ts**

```ts
/// <reference types="next" />
/// <reference types="next/image-types/global" />
```

Avoids type-check issues if someone runs `tsc --noEmit` before first build.

- [ ] **Step 10: Commit**

```bash
git add templates/nextjs-service/{{cookiecutter.project_slug}}/app/ templates/nextjs-service/{{cookiecutter.project_slug}}/next.config.ts templates/nextjs-service/{{cookiecutter.project_slug}}/tailwind.config.ts templates/nextjs-service/{{cookiecutter.project_slug}}/postcss.config.mjs templates/nextjs-service/{{cookiecutter.project_slug}}/tsconfig.json templates/nextjs-service/{{cookiecutter.project_slug}}/public/ templates/nextjs-service/{{cookiecutter.project_slug}}/next-env.d.ts
git commit -m "feat(nextjs-template): add Next.js App Router, TypeScript, Tailwind"
```

---

### Task 3: Create package.json and generate lockfile

**Files:**
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/package.json`

- [ ] **Step 1: Create package.json**

```json
{
  "name": "{{ cookiecutter.project_slug }}",
  "version": "1.0.0",
  "description": "{{ cookiecutter.description }}",
  "private": true,
  "packageManager": "pnpm@10.x",
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "node server.js",
    "test": "echo 'No tests yet'"
  },
  "dependencies": {
    "next": "^15.0.0",
    "react": "^19.0.0",
    "react-dom": "^19.0.0"
  },
  "devDependencies": {
    "@types/node": "^22",
    "@types/react": "^19",
    "@types/react-dom": "^19",
    "postcss": "^8",
    "tailwindcss": "^3.4.0",
    "typescript": "^5"
  }
}
```

- [ ] **Step 2: Generate pnpm-lock.yaml**

From project root:

```bash
cd templates/nextjs-service
cookiecutter . --output-dir /tmp/nextjs-scaffold --no-input
cd /tmp/nextjs-scaffold/my-service
pnpm install
cp pnpm-lock.yaml "$(git rev-parse --show-toplevel)/templates/nextjs-service/{{cookiecutter.project_slug}}/"
cd "$(git rev-parse --show-toplevel)"
rm -rf /tmp/nextjs-scaffold
```

(Default `project_slug` from "My Service" is `my-service`; adjust if you overrode `project_name`.)

- [ ] **Step 3: Verify build**

```bash
cd templates/nextjs-service && cookiecutter . --no-input project_name="Test" project_slug="test-app" description="Test" github_org="x" service_type="external" service_port="3000" docker_registry="ghcr.io" base_domain_dev="a.com" base_domain_test="a.com" base_domain_prod="c.com" memory_limit="512M"
cd test-app && pnpm install && pnpm build
```

Expected: Build succeeds, `.next/standalone` exists. Then `cd .. && rm -rf test-app` to avoid committing the scaffold.

- [ ] **Step 4: Commit**

```bash
git add templates/nextjs-service/{{cookiecutter.project_slug}}/package.json templates/nextjs-service/{{cookiecutter.project_slug}}/pnpm-lock.yaml
git commit -m "feat(nextjs-template): add package.json and lockfile"
```

---

## Chunk 2: Docker

### Task 4: Create Dockerfile

**Files:**
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/Dockerfile`

- [ ] **Step 1: Create Dockerfile**

```dockerfile
# Stage 1: deps
FROM node:24-alpine AS deps
WORKDIR /app
RUN corepack enable pnpm
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Stage 2: builder
FROM node:24-alpine AS builder
WORKDIR /app
RUN corepack enable pnpm
COPY --from=deps /app/node_modules ./node_modules
COPY . .
ENV NEXT_TELEMETRY_DISABLED=1
RUN pnpm build

# Stage 3: runner
FROM gcr.io/distroless/nodejs24-debian13:nonroot
WORKDIR /app
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=builder /app/public ./public
EXPOSE {{ cookiecutter.service_port }}
CMD ["node", "server.js"]
```

- [ ] **Step 2: Verify Docker build**

From a generated project (e.g. `test-app`):

```bash
docker build -t nextjs-test .
docker run -p 3000:3000 -e PORT=3000 nextjs-test
```

Expected: Container runs, app responds on port 3000. Next.js standalone listens on PORT.

- [ ] **Step 3: Commit**

```bash
git add templates/nextjs-service/{{cookiecutter.project_slug}}/Dockerfile
git commit -m "feat(nextjs-template): add multi-stage Dockerfile with standalone"
```

---

### Task 5: Create .dockerignore

**Files:**
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/.dockerignore`

- [ ] **Step 1: Create .dockerignore**

```
node_modules
.next
.git
.gitignore
README.md
.env
.env.*
!.env.example
*.md
Dockerfile
.dockerignore
.github
```

- [ ] **Step 2: Commit**

```bash
git add templates/nextjs-service/{{cookiecutter.project_slug}}/.dockerignore
git commit -m "feat(nextjs-template): add .dockerignore"
```

---

## Chunk 3: CI/CD and Deploy

### Task 6: Create GitHub workflows and deploy playbook

**Files:**
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/.github/workflows/emergency-deploy.yml`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/.github/deploy.yml`

- [ ] **Step 1: Create ci-cd.yml**

Copy from `templates/node-service/{{cookiecutter.project_slug}}/.github/workflows/ci-cd.yml`. Change the test job step from:

```yaml
run: pnpm install --frozen-lockfile && pnpm test
```

to:

```yaml
run: pnpm install --frozen-lockfile && pnpm build && pnpm test
```

All other content identical (prepare, build-and-push, deploy jobs).

- [ ] **Step 2: Create emergency-deploy.yml**

Copy from `templates/node-service/{{cookiecutter.project_slug}}/.github/workflows/emergency-deploy.yml` (identical).

- [ ] **Step 3: Create deploy.yml**

Copy from `templates/node-service/{{cookiecutter.project_slug}}/.github/deploy.yml` (identical).

- [ ] **Step 4: Commit**

```bash
git add templates/nextjs-service/{{cookiecutter.project_slug}}/.github/
git commit -m "feat(nextjs-template): add CI/CD and deploy workflows"
```

---

## Chunk 4: Config and Docs

### Task 7: Create docker-compose, .env.example, .gitignore, .cruft.json

**Files:**
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/docker-compose.yml`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/.env.example`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/.gitignore`
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/.cruft.json`

- [ ] **Step 1: Create docker-compose.yml**

Copy from `templates/node-service/{{cookiecutter.project_slug}}/docker-compose.yml` (identical).

- [ ] **Step 2: Create .env.example**

```
PORT={{ cookiecutter.service_port }}
```

- [ ] **Step 3: Create .gitignore**

```
.env
node_modules/
.next
```

- [ ] **Step 4: Create .cruft.json**

Copy from `templates/node-service/{{cookiecutter.project_slug}}/.cruft.json`, change `directory` to `templates/nextjs-service`:

```json
{
  "template": "https://github.com/{{ cookiecutter.github_org }}/mini-paas-starter",
  "commit": null,
  "context": {
    "cookiecutter": {
      "project_name": "{{ cookiecutter.project_name }}",
      "project_slug": "{{ cookiecutter.project_slug }}",
      "description": "{{ cookiecutter.description }}",
      "github_org": "{{ cookiecutter.github_org }}",
      "service_type": "{{ cookiecutter.service_type }}",
      "service_port": "{{ cookiecutter.service_port }}",
      "docker_registry": "{{ cookiecutter.docker_registry }}",
      "base_domain_dev": "{{ cookiecutter.base_domain_dev }}",
      "base_domain_test": "{{ cookiecutter.base_domain_test }}",
      "base_domain_prod": "{{ cookiecutter.base_domain_prod }}",
      "memory_limit": "{{ cookiecutter.memory_limit }}"
    }
  },
  "directory": "templates/nextjs-service",
  "checkout": null
}
```

- [ ] **Step 5: Commit**

```bash
git add templates/nextjs-service/{{cookiecutter.project_slug}}/docker-compose.yml templates/nextjs-service/{{cookiecutter.project_slug}}/.env.example templates/nextjs-service/{{cookiecutter.project_slug}}/.gitignore templates/nextjs-service/{{cookiecutter.project_slug}}/.cruft.json
git commit -m "feat(nextjs-template): add docker-compose, env, gitignore, cruft"
```

---

### Task 8: Create README.md

**Files:**
- Create: `templates/nextjs-service/{{cookiecutter.project_slug}}/README.md`

- [ ] **Step 1: Create README.md**

Copy from `templates/node-service/{{cookiecutter.project_slug}}/README.md` (identical content—same structure, secrets table, emergency deploy, env vars, internal service note).

- [ ] **Step 2: Commit**

```bash
git add templates/nextjs-service/{{cookiecutter.project_slug}}/README.md
git commit -m "feat(nextjs-template): add README"
```

---

### Task 9: Update project root README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add nextjs-service to Quick start**

In the "Scaffold a new app" section, change:

```bash
cruft create ./templates/go-service
# Or: ./templates/node-service, ./templates/python-service
```

to:

```bash
cruft create ./templates/go-service
# Or: ./templates/node-service, ./templates/nextjs-service, ./templates/python-service
```

- [ ] **Step 2: Add nextjs-service to Directory overview table**

Add row:

```
| `templates/nextjs-service/` | Next.js (App Router, TypeScript, Tailwind) Cookiecutter template |
```

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: add nextjs-service to README"
```

---

## Chunk 5: Verification

### Task 10: End-to-end verification

- [ ] **Step 1: Generate project**

```bash
cd /path/to/mini-paas-starter
cruft create ./templates/nextjs-service --no-input
# Or run interactively and fill prompts
```

- [ ] **Step 2: Local dev**

```bash
cd <generated-project>
corepack enable pnpm
pnpm install
pnpm dev
```

Expected: App runs on localhost:3000.

- [ ] **Step 3: Build**

```bash
pnpm build
```

Expected: Build succeeds, `.next/standalone` exists.

- [ ] **Step 4: Docker build and run**

```bash
docker build -t nextjs-test .
docker run -p 3000:3000 -e PORT=3000 nextjs-test
```

Expected: Container runs as non-root, app responds on port 3000.

- [ ] **Step 5: Test script**

```bash
pnpm test
```

Expected: Passes (echo 'No tests yet').

- [ ] **Step 6: Final commit**

```bash
git status
# Ensure all template files committed
```

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-03-17-nextjs-template.md`. Ready to execute?

**Execution path:** Use @superpowers:subagent-driven-development or @superpowers:executing-plans to implement. Each task is self-contained; run in order. Verification (Task 10) confirms the template works end-to-end.

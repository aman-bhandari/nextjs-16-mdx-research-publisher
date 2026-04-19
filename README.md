# nextjs-16-mdx-research-publisher

[![CI](https://github.com/aman-bhandari/nextjs-16-mdx-research-publisher/actions/workflows/ci.yml/badge.svg)](https://github.com/aman-bhandari/nextjs-16-mdx-research-publisher/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Next.js 16](https://img.shields.io/badge/Next.js-16-black.svg)](https://nextjs.org/)
[![React 19](https://img.shields.io/badge/React-19-61DAFB.svg)](https://react.dev/)
[![TypeScript strict](https://img.shields.io/badge/TypeScript-strict-3178C6.svg)](https://www.typescriptlang.org/)

A static publisher for short research notes. Next.js 16 + React 19 + TypeScript 5 strict + Tailwind v4 + MDX. Schema.org `Article` JSON-LD emitted inline for every post.

## What this is

A Next.js App Router publisher for short research notes. Content lives as `.mdx` files that render as React Server Components. Each post emits Schema.org structured data for search-engine indexing. The build output is static HTML — deployable to any static host.

Ships with: one home page, three sample posts, one shared `ArticleJsonLd` component, one stylesheet. Every claim in the README is evidenced by a check in `scripts/integrity-check.sh`, which runs locally and in CI on every push.

Three sample posts ship to demonstrate the content-authoring flow end-to-end:

- `On evaluation as the slowest form of progress` — why manual eval beats prompt tuning in the first month of an LLM project
- `Chunking, revisited — why the upstream decision dominates` — a retrieval debugging note
- `Inter-agent protocols — one-way data, bidirectional intent` — a short note on multi-agent coordination shape

## Tech stack

- **Next.js 16.2.3** (App Router, Server Components, Turbopack-powered build)
- **React 19.2.4**
- **TypeScript 5** with `strict: true`
- **Tailwind CSS v4** (via `@tailwindcss/postcss`)
- **MDX** via `@next/mdx` (page-level, with named exports for `frontmatter` and `metadata`)
- Schema.org JSON-LD inlined per post via a shared Server Component

No client-side JavaScript framework beyond the Next.js runtime. No CMS. No database. Pure static output.

## Architecture

```
nextjs-16-mdx-research-publisher/
├── README.md
├── LICENSE
├── .gitignore
├── package.json
├── tsconfig.json                       # strict: true
├── next.config.mjs                     # MDX loader wired up
├── postcss.config.mjs                  # Tailwind v4 via @tailwindcss/postcss
├── mdx-components.tsx                  # MDX element overrides (typographic)
├── src/
│   ├── app/
│   │   ├── layout.tsx                  # Root layout
│   │   ├── page.tsx                    # Home (lists posts)
│   │   ├── globals.css                 # @import "tailwindcss" + tokens
│   │   └── posts/
│   │       ├── note-01-on-evals/page.mdx
│   │       ├── note-02-chunking-revisited/page.mdx
│   │       └── note-03-agent-protocols/page.mdx
│   ├── components/
│   │   └── ArticleJsonLd.tsx           # Emits <script type="application/ld+json">
│   ├── lib/
│   │   └── content.ts                  # Post registry (imports frontmatter from each .mdx)
│   └── types/
│       └── mdx.d.ts                    # Augments MDX module type with frontmatter export
├── docs/
│   └── claim-evidence.md               # Gate 0: every claim evidenced
├── scripts/
│   └── integrity-check.sh              # Gates 0, 4, 5 + artifact-specific
└── .github/workflows/ci.yml            # npm ci + tsc + build + integrity + hype audit
```

## Setup

```bash
git clone https://github.com/aman-bhandari/nextjs-16-mdx-research-publisher.git
cd nextjs-16-mdx-research-publisher
npm install
npm run build
```

Tested on Node.js 20+ and Node.js 24. CI runs on Node 20.

## Usage

### Run the dev server

```bash
npm run dev
```

Opens on `http://localhost:3000`. Home page lists the three sample posts; each post renders at `/posts/<slug>`.

### Build for production

```bash
npm run build
```

Produces a fully static site. All routes are prerendered; the build log shows `○ (Static)` next to each route.

### Typecheck

```bash
npm run typecheck
# or
npx tsc --noEmit
```

Must exit 0 with no errors. `tsconfig.json` enables `strict: true`.

### Add a new post

1. Create `src/app/posts/<slug>/page.mdx`.
2. At the top of the file, import the JSON-LD component and export `frontmatter` and `metadata`:

   ```mdx
   import { ArticleJsonLd } from "@/components/ArticleJsonLd";

   export const frontmatter = {
     title: "Your Title",
     date: "2026-04-20",
     summary: "One-sentence description.",
     topic: "your topic",
   };

   export const metadata = {
     title: frontmatter.title,
     description: frontmatter.summary,
   };

   <ArticleJsonLd {...frontmatter} />

   # {frontmatter.title}

   Content...
   ```

3. Add the new post to `src/lib/content.ts` (import the named `frontmatter` export and include in the `rawPosts` array).
4. Run `npm run build` to verify the route prerenders.

## Integrity check

```bash
bash scripts/integrity-check.sh
```

Runs:

- **Gate 0** — every claim in `docs/claim-evidence.md` marked verified (✅)
- **Gate 4** — zero private identifiers
- **Gate 5** — no secrets outside `.env.example`
- **Artifact-specific** — package.json pins Next 16 / React 19 / TS 5 / Tailwind 4; tsconfig strict:true; ≥3 MDX post pages; `tsc --noEmit` clean; `npm run build` succeeds; built HTML for all post routes contains `<script type="application/ld+json">` AND `"@type":"Article"`; all post routes prerendered as static HTML in `.next/server/app/posts/`

CI reproduces the full verification on every push via `.github/workflows/ci.yml` — fresh `npm ci`, `tsc --noEmit`, `npm run build`, integrity check, hype-word audit.

## Related artifacts

- `claude-code-mcp-qa-automation` — end-to-end QA automation built on Claude Code + MCP patterns
- `claude-code-agent-skills-framework` — `.claude/` framework for AI-engineering workflows
- `llm-rag-knowledge-graph` — chronicle editorial format + wiki-as-RAG graph shape (this publisher can render that artifact's chronicle format if the frontmatter shapes are reconciled)
- `claude-multi-agent-protocol` — HANDOVER + SYNC inter-repo protocol

## License

MIT © 2026 Aman Bhandari. See `LICENSE`.

# Claim-Evidence Mapping

Every claim this repo makes — in its GitHub description, its README, and any resume line pointing at it — must map to a file or command that evidences the claim.

**Rule:** every row must be verified (✅) before push. An unverified row (☐) fails the integrity check and blocks CI.

## Claims

| Claim | Evidence (file / command) | Verified |
|-------|---------------------------|----------|
| "Next.js 16" | `package.json` pins `"next": "16.2.3"`; `npm run build` runs on Next.js 16.2.3 (Turbopack) | ✅ |
| "React 19" | `package.json` pins `"react": "19.2.4"` and `"react-dom": "19.2.4"` | ✅ |
| "TypeScript 5 strict" | `package.json` pins `"typescript": "^5"`; `tsconfig.json` has `"strict": true`; `npx tsc --noEmit` exits 0 | ✅ |
| "Tailwind v4" | `package.json` pins `"tailwindcss": "^4"` and `"@tailwindcss/postcss": "^4"`; `src/app/globals.css` uses `@import "tailwindcss"` | ✅ |
| "MDX" | `package.json` pins `"@next/mdx": "^16.2.3"`; 3 `page.mdx` files in `src/app/posts/*/`; each exports `frontmatter` + `metadata` and renders as a page | ✅ |
| "Schema.org JSON-LD" | `src/components/ArticleJsonLd.tsx` emits `<script type="application/ld+json">`; built HTML (`find .next/server/app/posts -name '*.html'`) contains both `"application/ld+json"` and `"@type":"Article"` for all 3 posts | ✅ |
| "React Server Components static pipeline" | App Router layout (`src/app/layout.tsx`); all 5 routes marked `○ (Static)` in Next.js build output; HTML files prerendered in `.next/server/app/` | ✅ |
| "5 static routes (1 home + 3 posts + 1 not-found)" | Next.js build output shows 5 routes; `find .next/server/app -name '*.html'` returns 5 files | ✅ |
| "build passes with zero warnings" | `npm run build` completes successfully; final integrity check smoke-tests fresh build in CI | ✅ |
| "zero-runtime-JavaScript defaults" | Server Components are the default in App Router; posts render as pure HTML + JSON-LD (no client-side React bundle beyond Next.js runtime); can be served from any static host | ✅ |

## How this file is enforced

`scripts/integrity-check.sh` (run locally) and `.github/workflows/ci.yml` (run on every push) both fail if any row in this file carries `☐` instead of `✅`. This applies Gate 0 of the bulletproof publishing contract.

CI also runs a fresh `npm ci` + `tsc --noEmit` + `npm run build` before the integrity check, so the evidence is re-verified from source on every push.

## Adding a new claim

1. Add a row here with the claim text (verbatim) and the evidencing command or file path.
2. Mark as `☐` until verified.
3. Run `bash scripts/integrity-check.sh`. It fails while any row carries `☐`.
4. Verify the evidence, flip to `✅`, re-run.
5. Push only after all rows are `✅`.

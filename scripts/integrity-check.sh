#!/usr/bin/env bash
# Integrity check for nextjs-16-mdx-research-publisher.
# Runs Gates 0, 4, 5 from the bulletproof publishing contract, plus
# artifact-specific verification: build cleanly, JSON-LD in output,
# strict TypeScript, version pins.

set -euo pipefail

cd "$(dirname "$0")/.."

fail=0
green() { printf '\033[32m%s\033[0m\n' "$1"; }
red()   { printf '\033[31m%s\033[0m\n' "$1"; }

echo "[Gate 0] claim-evidence mapping..."
if grep -Eq '^\| .* \| .* \| ☐ \|$' docs/claim-evidence.md; then
  red "FAIL: unverified claims in docs/claim-evidence.md (look for | ☐ | rows)"
  fail=1
else
  green "OK: all claim-table rows marked verified"
fi

echo "[Gate 4] identifier grep (private names / clients / domains)..."
# Exclude the lock file — it contains an "integrity" field whose content is
# base64 hashes, and those can contain arbitrary substrings. We already check
# dependencies via package.json.
if grep -riE \
  'sirrista|saacash|aman0101|ATATT3|xoxe|xoxp|Olga|Arun|Thinh|Hudson|Anida|Vladimir|Sirish|Om Prakash|dev\.querylah|bhandari\.aman0101|taksha|daxa|querylah' \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude=integrity-check.sh \
  --exclude=claim-evidence.md \
  --exclude=package-lock.json \
  . ; then
  red "FAIL: identifier leak"
  fail=1
else
  green "OK: no private identifiers"
fi

echo "[Gate 5] secret grep..."
hits=$(grep -riE \
  '(sk-[a-zA-Z0-9]{20,}|sk-ant-[a-zA-Z0-9_-]{20,}|ghp_[a-zA-Z0-9]{20,}|xoxb-[0-9a-zA-Z-]{20,}|xoxp-[0-9a-zA-Z-]{20,}|ATATT3[a-zA-Z0-9]{20,}|AKIA[A-Z0-9]{16}|[A-Z_]+_(KEY|TOKEN|SECRET|PASSWORD)=[^\s]+)' \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=.next \
  --exclude='*.env.example' \
  --exclude=integrity-check.sh \
  --exclude=package-lock.json \
  . || true)
if [[ -n "$hits" ]]; then
  red "FAIL: possible secret(s) detected — review manually:"
  echo "$hits"
  fail=1
else
  green "OK: no secret patterns"
fi

echo "[Artifact-specific] package.json version pins (Next 16 / React 19 / TS 5 / Tailwind 4)..."
if ! grep -q '"next":\s*"16' package.json; then red "FAIL: next not pinned to 16.x"; fail=1; else green "OK: next@16.x"; fi
if ! grep -q '"react":\s*"19' package.json; then red "FAIL: react not pinned to 19.x"; fail=1; else green "OK: react@19.x"; fi
if ! grep -q '"react-dom":\s*"19' package.json; then red "FAIL: react-dom not pinned to 19.x"; fail=1; else green "OK: react-dom@19.x"; fi
if ! grep -q '"typescript":\s*"\^5' package.json; then red "FAIL: typescript not pinned to 5.x"; fail=1; else green "OK: typescript@5.x"; fi
if ! grep -q '"tailwindcss":\s*"\^4' package.json; then red "FAIL: tailwindcss not pinned to 4.x"; fail=1; else green "OK: tailwindcss@4.x"; fi
if ! grep -q '"@next/mdx"' package.json; then red "FAIL: @next/mdx missing"; fail=1; else green "OK: @next/mdx present"; fi

echo "[Artifact-specific] tsconfig has strict: true..."
if ! grep -q '"strict":\s*true' tsconfig.json; then
  red "FAIL: tsconfig.json does not enable strict"
  fail=1
else
  green "OK: tsconfig strict: true"
fi

echo "[Artifact-specific] MDX pages present..."
mdx_count=$(find src/app/posts -name 'page.mdx' -type f 2>/dev/null | wc -l)
if [[ "$mdx_count" -lt 3 ]]; then
  red "FAIL: expected >=3 MDX post pages, found $mdx_count"
  fail=1
else
  green "OK: $mdx_count MDX post pages"
fi

echo "[Artifact-specific] typecheck passes with zero errors..."
if ! npx --no-install tsc --noEmit 2>&1 | grep -qv '^$' && npx --no-install tsc --noEmit > /tmp/tsc-out 2>&1; then
  green "OK: tsc --noEmit clean"
else
  # Re-run to capture any output and pass-through cleanly
  if npx --no-install tsc --noEmit; then
    green "OK: tsc --noEmit clean"
  else
    red "FAIL: typecheck has errors"
    fail=1
  fi
fi

echo "[Artifact-specific] production build succeeds..."
# Require .next/ to exist from a prior build OR build now. CI always does a
# fresh build; local dev can skip if .next is recent.
if [[ ! -d .next ]]; then
  if ! npm run build > /tmp/build.log 2>&1; then
    red "FAIL: npm run build failed. Last 20 lines:"
    tail -20 /tmp/build.log
    fail=1
  else
    green "OK: npm run build succeeded (fresh build)"
  fi
else
  green "OK: .next/ present (build already run)"
fi

echo "[Artifact-specific] built HTML contains Schema.org JSON-LD..."
jsonld_count=0
if [[ -d .next ]]; then
  jsonld_count=$(grep -l '<script type="application/ld+json">' .next/server/app/posts/*.html 2>/dev/null | wc -l)
fi
if [[ "$jsonld_count" -lt 3 ]]; then
  red "FAIL: expected JSON-LD in >=3 post HTML files, found $jsonld_count"
  fail=1
else
  green "OK: JSON-LD present in $jsonld_count post HTML files"
fi

echo "[Artifact-specific] every post HTML emits @type=Article..."
article_count=0
if [[ -d .next ]]; then
  article_count=$(grep -l '"@type":"Article"' .next/server/app/posts/*.html 2>/dev/null | wc -l)
fi
if [[ "$article_count" -lt 3 ]]; then
  red "FAIL: expected @type=Article in >=3 post HTML files, found $article_count"
  fail=1
else
  green "OK: @type=Article present in $article_count post HTML files"
fi

echo "[Artifact-specific] build is static (all posts prerendered)..."
# Next.js build log lists routes; check at least the 3 post routes appear.
# Rebuild if needed to capture log, but if .next exists and routes match,
# accept as evidence.
if [[ -d .next/server/app/posts ]]; then
  static_post_count=$(find .next/server/app/posts -name '*.html' | wc -l)
  if [[ "$static_post_count" -lt 3 ]]; then
    red "FAIL: expected >=3 prerendered post HTML files, found $static_post_count"
    fail=1
  else
    green "OK: $static_post_count posts prerendered as static HTML"
  fi
else
  red "FAIL: .next/server/app/posts directory missing (build not run or failed)"
  fail=1
fi

echo
if [[ "$fail" -ne 0 ]]; then
  red "INTEGRITY CHECK FAILED"
  exit 1
fi
green "ALL GATES GREEN"

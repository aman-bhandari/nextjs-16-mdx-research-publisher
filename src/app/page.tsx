import Link from "next/link";
import { posts } from "@/lib/content";

export default function HomePage() {
  return (
    <main className="prose">
      <header className="mb-10">
        <h1 className="text-3xl font-semibold tracking-tight">Research Notes</h1>
        <p className="mt-3 text-[color:var(--muted)]">
          A static publisher for short research notes. Every post is an MDX
          file rendered as a React Server Component. Schema.org JSON-LD is
          emitted inline for each article.
        </p>
      </header>

      <ul className="space-y-6">
        {posts.map((post) => (
          <li
            key={post.slug}
            className="border-b border-stone-200 pb-6 last:border-0"
          >
            <time className="text-xs uppercase tracking-wide text-[color:var(--muted)]">
              {post.date} · {post.topic}
            </time>
            <h2 className="mt-1 text-xl font-semibold">
              <Link href={post.href}>{post.title}</Link>
            </h2>
            <p className="mt-2 text-[color:var(--muted)]">{post.summary}</p>
          </li>
        ))}
      </ul>

      <footer className="mt-16 border-t border-stone-200 pt-6 text-sm text-[color:var(--muted)]">
        <p>
          {posts.length} post{posts.length === 1 ? "" : "s"}. Built with Next.js
          16, React 19, TypeScript 5 strict, Tailwind v4, MDX.
        </p>
      </footer>
    </main>
  );
}

import { frontmatter as fm01 } from "@/app/posts/note-01-on-evals/page.mdx";
import { frontmatter as fm02 } from "@/app/posts/note-02-chunking-revisited/page.mdx";
import { frontmatter as fm03 } from "@/app/posts/note-03-agent-protocols/page.mdx";

export type PostFrontmatter = {
  title: string;
  date: string;
  summary: string;
  topic: string;
};

export type Post = PostFrontmatter & { slug: string; href: string };

const rawPosts: Array<PostFrontmatter & { slug: string }> = [
  { slug: "note-01-on-evals", ...fm01 },
  { slug: "note-02-chunking-revisited", ...fm02 },
  { slug: "note-03-agent-protocols", ...fm03 },
];

export const posts: Post[] = rawPosts
  .map((p) => ({ ...p, href: `/posts/${p.slug}` }))
  .sort((a, b) => b.date.localeCompare(a.date));

import type { PostFrontmatter } from "@/lib/content";

export function ArticleJsonLd({
  title,
  date,
  summary,
  topic,
}: PostFrontmatter) {
  const structured = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: title,
    description: summary,
    datePublished: date,
    articleSection: topic,
    author: {
      "@type": "Organization",
      name: "Research Publisher",
    },
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(structured) }}
    />
  );
}

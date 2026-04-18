declare module "*.mdx" {
  import type { ComponentType } from "react";

  export const frontmatter: {
    title: string;
    date: string;
    summary: string;
    topic: string;
  };

  export const metadata: {
    title: string;
    description: string;
  };

  const MDXComponent: ComponentType;
  export default MDXComponent;
}

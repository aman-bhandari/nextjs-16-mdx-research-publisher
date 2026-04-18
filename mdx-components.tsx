import type { MDXComponents } from "mdx/types";

export function useMDXComponents(components: MDXComponents): MDXComponents {
  return {
    ...components,
    h1: (props) => (
      <h1
        className="mt-0 mb-6 text-3xl font-semibold tracking-tight"
        {...props}
      />
    ),
    h2: (props) => (
      <h2 className="mt-10 mb-3 text-xl font-semibold" {...props} />
    ),
    h3: (props) => (
      <h3 className="mt-6 mb-2 text-lg font-semibold" {...props} />
    ),
    p: (props) => <p className="my-4 leading-7" {...props} />,
    ul: (props) => <ul className="my-4 list-disc pl-6" {...props} />,
    ol: (props) => <ol className="my-4 list-decimal pl-6" {...props} />,
    li: (props) => <li className="my-1" {...props} />,
    pre: (props) => (
      <pre
        className="my-4 overflow-x-auto rounded-md bg-stone-900 p-4 text-sm text-stone-50"
        {...props}
      />
    ),
    blockquote: (props) => (
      <blockquote
        className="my-4 border-l-4 border-stone-300 pl-4 italic text-[color:var(--muted)]"
        {...props}
      />
    ),
  };
}

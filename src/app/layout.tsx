import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: {
    default: "Research Publisher",
    template: "%s — Research Publisher",
  },
  description:
    "A Next.js 16 + React 19 + MDX static publisher with Schema.org JSON-LD structured data. Zero-runtime-JavaScript defaults for research notes.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="min-h-screen antialiased">
        <div className="mx-auto max-w-3xl px-6 py-12">{children}</div>
      </body>
    </html>
  );
}

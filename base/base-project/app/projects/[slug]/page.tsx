// app/projects/[slug]/page.tsx
import { notFound } from "next/navigation";
import { getProjectById as getProjectBySlug, getProjects } from "@/lib/data";
import Link from "next/link";

export async function generateStaticParams() {
  const projects = await getProjects();
  return projects.map((p) => ({ slug: p.id }));
}

export default async function ProjectPage({
  params,
}: {
  params: { slug: string };
}) {
  const resolvedParams = await params; // this is always a promise
  const project = await getProjectBySlug(resolvedParams.slug);

  if (!project) {
    notFound();
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-4xl font-bold mb-4">{project.title}</h1>
      <div className="w-full h-64 bg-gray-200 dark:bg-gray-700 rounded-lg mb-8 flex items-center justify-center">
        <span className="text-gray-500">Image placeholder</span>
      </div>
      <p className="text-lg mb-8">{project.description}</p>
      {project.url && (
        <Link
          href={project.url}
          target="_blank"
          rel="noopener noreferrer"
          className="inline-block bg-indigo-600 text-white px-6 py-3 rounded-lg font-semibold hover:bg-indigo-700 transition-colors"
        >
          Visit Project
        </Link>
      )}
    </div>
  );
}

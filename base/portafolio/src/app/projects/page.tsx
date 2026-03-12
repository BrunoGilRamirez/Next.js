import { getProjects } from "./_lib/data";
import { ProjectItem } from "./_components/ProjectItem";

export default async function ProjectsPage() {
  const projects = await getProjects();
  return (
    <section>
      <h1 className="text-3xl font-bold mb-8">My Projects</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        {projects.map((p) => (
          <ProjectItem key={p.id} id={p.id} title={p.title} />
        ))}
      </div>
    </section>
  );
}

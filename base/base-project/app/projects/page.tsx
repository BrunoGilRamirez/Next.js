import { useRouter } from "next/router";
import { getProjects } from "../../lib/data";

export default async function Page() {
  const projects = await getProjects();
  const navigateToProject = (id: string) => {
    // take the user to /projects/[id]
    useRouter().push(`/projects/${id}`);
  };
  return (
    <ul>
      {projects.map((p) => (
        <li key={p.id}>
          {p.title}
          <button onClick={() => navigateToProject(p.id)}>View Details</button>
        </li>
      ))}
    </ul>
  );
}

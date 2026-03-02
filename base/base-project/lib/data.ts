// lib/data.ts
"use server";
import projectsData from "../data/projects.json";
import Project from "../types/project";

export async function getProjects(): Promise<Project[]> {
  // Reading from local JSON — valid for portfolio MVP
  return projectsData;
}

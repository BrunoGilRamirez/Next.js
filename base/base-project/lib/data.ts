// lib/data.ts
"use server";
import projectsData from "../data/projects.json";
import Project from "../types/project";
import { cache } from "react";

export const getProjects = cache(async (): Promise<Project[]> => {
  return projectsData;
});

export const getProjectById = cache(
  async (id: string): Promise<Project | null> => {
    console.log(id);
    return projectsData.find((p) => p.id === id) ?? null;
  },
);

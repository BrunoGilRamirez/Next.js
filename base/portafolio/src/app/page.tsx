export default function Home() {
  return (
    <section className="text-center">
      <h1 className="text-4xl font-bold tracking-tight text-foreground sm:text-6xl">
        Welcome to My Portfolio
      </h1>
      <p className="mt-6 text-lg leading-8 text-foreground/80">
        This is a showcase of my projects and skills.
      </p>
      <div className="mt-10 flex items-center justify-center gap-x-6">
        <a
          href="/projects"
          className="rounded-md bg-indigo-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
        >
          See My Projects
        </a>
        <a href="/contact" className="text-sm font-semibold leading-6 text-foreground">
          Contact me <span aria-hidden="true">→</span>
        </a>
      </div>
    </section>
  );
}

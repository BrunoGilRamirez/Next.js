import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // -------------- Server --------------
  // server: "http://localhost:3000",
  // -------------- Images --------------
  // images: {
  //   domains: ["example.com"],
  // },
  // -------------- General --------------
  // reactStrictMode: true, // enable strict mode
  // swcMinify: true, // enable minification
  // distDir: "dist", // change the output directory
  // -------------- Rewrites --------------
  // async rewrites() {
  //   return [
  //     {
  //       source: "/about",
  //       destination: "/about-us",
  //     },
  //   ];
  // }, // transparently rewrite routes, like a reverse proxy
  // -------------- Headers --------------
  // async headers() {
  //   return [
  //     {
  //       source: "/(.*)",
  //       headers: [
  //         {
  //           key: "X-Frame-Options",
  //           value: "DENY",
  //         },
  //       ],
  //     },
  //   ];
  // }, // add custom headers to responses, and you can set up:
  //   - Content Security Policy (CSP)
  //   - Cache-Control headers
  //   - X-Frame-Options
  //   - X-XSS-Protection
  //   - X-Content-Type-Options
  //   - Referrer-Policy
  //   - Permissions-Policy
  //   - CORS headers and more
};

export default nextConfig;

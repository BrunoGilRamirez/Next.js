// .eslintrc.js
module.exports = {
  root: true,
  extends: [
    "next/core-web-vitals", // reglas recomendadas por Next.js
    "eslint:recommended",
    "plugin:@typescript-eslint/recommended",
  ],
  parser: "@typescript-eslint/parser",
  plugins: ["@typescript-eslint"],
  rules: {
    // 🔧 Desactiva la regla que obliga a usar &apos; o &#39;
    "react/no-unescaped-entities": "off",

    // Opcionales: buenas prácticas adicionales
    "@typescript-eslint/no-unused-vars": ["warn", { argsIgnorePattern: "^_" }],
    "no-console": ["warn", { allow: ["warn", "error"] }],
    semi: ["error", "always"],
    quotes: ["error", "single"],
  },
  overrides: [
    {
      files: ["*.ts", "*.tsx"],
      rules: {
        // Ejemplo: puedes ajustar reglas solo para TS/TSX
        "@typescript-eslint/explicit-module-boundary-types": "off",
      },
    },
  ],
};

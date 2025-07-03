const fs = require("fs");
const path = require("path");

const gitignorePattern = fs
  .readFileSync(path.join(__dirname, ".gitignore"), "utf8")
  .split("\n")
  .filter((line) => line && !line.startsWith("#"));

module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  ignorePatterns: [...gitignorePattern],
  parser: "@typescript-eslint/parser",
  overrides: [
    {
      files: ["*.ts", "*.tsx"],
      extends: ["standard-with-typescript", "prettier"],
      rules: {
        "@typescript-eslint/explicit-function-return-type": "off",
        "@typescript-eslint/strict-boolean-expressions": "off",
      },
    },
    {
      files: ["*.cjs", "*.js", "*.jsx"],
      extends: ["standard", "prettier"],
    },
  ],
  rules: {
    "sort-imports": ["error", { ignoreDeclarationSort: true }],
    "import/order": ["error", { alphabetize: { order: "asc" }, "newlines-between": "never" }],
  },
};

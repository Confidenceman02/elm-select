import typescript from "@rollup/plugin-typescript";
import pkg from "./package.json";
import { uglify } from "rollup-plugin-uglify";

export default {
  input: "src/index.ts",
  output: [
    { file: pkg.main, format: "cjs" },
    { file: pkg.module, format: "es" },
    { file: pkg.browser, format: "umd", name: "ElmSelect" },
    {
      file: "dist/dynamic.min.js",
      format: "umd",
      globals: { "@icelab/defo": "Defo" },
    },
  ],
  plugins: [uglify(), typescript({ typescript: require("typescript") })],
  external: ["@icelab/defo"],
};

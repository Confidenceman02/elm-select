import typescript from "@rollup/plugin-typescript";
import { uglify } from "rollup-plugin-uglify";

export default {
  input: "src/index.ts",
  output: {
    file: "dist/dynamic.min.js",
    format: "umd",
    globals: { "@icelab/defo": "defo" },
  },
  plugins: [uglify(), typescript({ typescript: require("typescript") })],
  external: ["@icelab/defo"],
};

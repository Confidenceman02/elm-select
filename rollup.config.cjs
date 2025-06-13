const typescript = require("@rollup/plugin-typescript");
const terser = require("@rollup/plugin-terser");
const { nodeResolve } = require("@rollup/plugin-node-resolve");

module.exports = {
  input: "src/index.ts",
  output: [
    { file: "dist/dynamic.js", format: "cjs" },
    { file: "dist/dynamic.es.js", format: "es" },
    { file: "dist/dynamic.bundle.js", format: "umd", name: "ElmSelect" },
    {
      file: "dist/dynamic.min.js",
      format: "umd",
      globals: { "@icelab/defo": "Defo" },
    },
  ],
  plugins: [
    nodeResolve(),
    terser(),
    typescript({ typescript: require("typescript") }),
  ],
};

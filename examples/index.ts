//@ts-ignore
import { Elm } from "./Main.elm";

const app = Elm.Main.init({
  node: document.querySelector("main"),
  flags: null,
});

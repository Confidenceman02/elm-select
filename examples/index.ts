//@ts-ignore
import { Elm } from "./Main.elm";
import "@confidenceman02/elm-select";

const app = Elm.Main.init({
  node: document.querySelector("main"),
  flags: null,
});

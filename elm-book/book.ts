//@ts-ignore
import { Elm } from "./src/Book.elm";

const app = Elm.Book.init({
  node: document.querySelector("main"),
});

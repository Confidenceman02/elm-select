import defo from "@icelab/defo";
import { viewObservers } from "./viewObservers";

/**
 * Set defo prefix to `es`. This means we call it in the DOM with the convention:
 *
 *    data-es-#{view-observer-name}={...}
 */
const prefix = "es";

defo({ prefix, views: viewObservers });

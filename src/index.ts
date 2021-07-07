import defo from "@icelab/defo";

/**
 * Set defo prefix to `ex`. This means we call it in the DOM with the convention:
 *
 *    data-ex-#{view-observer-name}={...}
 */
const prefix = "ex";

defo({ prefix, views: {} });

import defo from "@icelab/defo";

/**
 * Set defo prefix to `ex`. This means we call it in the DOM with the convention:
 *
 *    data-es-#{view-observer-name}={...}
 */
const prefix = "es";

defo({ prefix, views: {} });

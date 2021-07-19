"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const defo_1 = __importDefault(require("@icelab/defo"));
const viewObservers_1 = require("./viewObservers");
/**
 * Set defo prefix to `es`. This means we call it in the DOM with the convention:
 *
 *    data-es-#{view-observer-name}={...}
 */
const prefix = "es";
defo_1.default({ prefix, views: viewObservers_1.viewObservers });

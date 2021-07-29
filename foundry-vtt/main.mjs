#!/usr/bin/env node

// Require Node.js v14+
const startupMessages = [];
const nodeVer = process.versions.node;
startupMessages.push({level: "info", message: `Running on Node.js - Version ${nodeVer}`});
if (nodeVer.split(".").shift() < 14) {
  console.error(`Foundry Virtual Tabletop requires Node.js version 14.x or greater.`);
  process.exit(1);
}

// Import Initial Modules
import fs from "fs";
import { fileURLToPath } from 'url';
import path from 'path';

/**
 * Invoke application initialization workflow
 * @returns {Promise<void>}
 */
(async function () {
  const main = fileURLToPath(import.meta.url);
  const root = path.dirname(main);
  const isDebug = process.argv.includes("--debug") && fs.existsSync(`./server`);
  const init = await import(isDebug ? "./server/init.mjs" : "./dist/init.mjs");
  await init.default({
    args: process.argv,
    root: root,
    messages: startupMessages,
    debug: isDebug
 });
 (await import("./plutonium-backend.mjs")).Plutonium.init();
 })();

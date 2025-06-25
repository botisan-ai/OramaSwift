import { count, create, getByID, insert, search } from "@orama/orama";

import { persist, restore } from "./persistence";

export { create, insert, search, getByID, count, persist, restore };

// this file is loaded into a JSContext in JavaScriptCore
// so we will keep the database inside the global scope in this context
// and use these methods to interact with it

export function helloWorld(): string {
  return "Hello World";
}

export async function helloWorldAsync(): Promise<string> {
  // Simple async function that resolves immediately
  return Promise.resolve("Hello World");
}

// usually exported functions are avaiable under a scoped variable (configured in tsup)

// You can optionally make the functions available globally for JavaScriptCore
// (globalThis as any).helloWorld = helloWorld;
// (globalThis as any).helloWorldAsync = helloWorldAsync;

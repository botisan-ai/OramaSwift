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

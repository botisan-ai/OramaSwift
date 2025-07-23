import {
  type AnyOrama,
  type AnySchema,
  count,
  create,
  getByID,
  insert,
  upsert,
  load,
  remove,
  save,
  search,
} from "@orama/orama";

import { intlSegmenterTokenizer } from "./tokenizer";
import type { BreakIterator } from "./intl-segmenter";

export { create, insert, upsert, remove, search, getByID, count };

// this file is based off  the @orama/plugin-data-persistence plugin
// but stripped down to just the JSON serialization and deserialization

export function persist(db: AnyOrama): string {
  const dbExport = save(db);
  const serialized = JSON.stringify(dbExport);
  return serialized;
}

export function restore(data: string): AnyOrama {
  const db = create({
    schema: {
      __placeholder: "string",
    },
  });

  const deserialized = JSON.parse(data);

  load(db, deserialized);

  return db;
}

// this file is loaded into a JSContext in JavaScriptCore
// so we will keep the database inside the global scope in this context
// and use these methods to interact with it

/**
 * Creates a new Orama instance with the provided schema and multilingual support.
 *
 * @param schema - The schema to use for the Orama instance.
 * @param languages - An array of language codes to support multilingual tokenization (ISO 639-1 codes).
 * @returns A new Orama instance configured with the provided schema and tokenizer.
 */
export function createMultilingual(
  breakIterator: BreakIterator,
  schema: AnySchema,
  languages: string[],
): AnyOrama {
  return create({
    schema,
    components: {
      tokenizer: intlSegmenterTokenizer({
        languages,
        breakIterator,
      }),
    },
  });
}

export function restoreMultilingual(
  breakIterator: BreakIterator,
  languages: string[],
  data: string,
): AnyOrama {
  const db = create({
    schema: {
      __placeholder: "string",
    },
    components: {
      tokenizer: intlSegmenterTokenizer({
        languages,
        breakIterator,
      }),
    },
  });

  const deserialized = JSON.parse(data);

  load(db, deserialized);

  return db;
}

// keeping sample methods just to show how JavaScriptCore works

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

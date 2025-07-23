import { AnyOrama, AnySchema } from '@orama/orama';
export { count, create, getByID, insert, remove, search, upsert } from '@orama/orama';

interface BreakIteratorResult {
    start: number;
    end: number;
    type: number;
}
interface BreakIterator {
    utf8BreakIteratorWithBreakTypeLocaleTextToBreak: (breakType: number, locale: string, textToBreak: string) => BreakIteratorResult[];
}

declare function persist(db: AnyOrama): string;
declare function restore(data: string): AnyOrama;
/**
 * Creates a new Orama instance with the provided schema and multilingual support.
 *
 * @param schema - The schema to use for the Orama instance.
 * @param languages - An array of language codes to support multilingual tokenization (ISO 639-1 codes).
 * @returns A new Orama instance configured with the provided schema and tokenizer.
 */
declare function createMultilingual(breakIterator: BreakIterator, schema: AnySchema, languages: string[]): AnyOrama;
declare function restoreMultilingual(breakIterator: BreakIterator, languages: string[], data: string): AnyOrama;
declare function helloWorld(): string;
declare function helloWorldAsync(): Promise<string>;

export { createMultilingual, helloWorld, helloWorldAsync, persist, restore, restoreMultilingual };

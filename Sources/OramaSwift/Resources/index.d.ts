import { AnyOrama } from '@orama/orama';
export { create, insert, search } from '@orama/orama';

declare function persist(db: AnyOrama): string;
declare function restore(data: string): AnyOrama;

declare function helloWorld(): string;
declare function helloWorldAsync(): Promise<string>;

export { helloWorld, helloWorldAsync, persist, restore };

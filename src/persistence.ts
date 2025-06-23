import type { AnyOrama } from '@orama/orama';
import { create, load, save } from '@orama/orama';

// this file is based off  the @orama/plugin-data-persistence plugin
// but stripped down to just the JSON serialization and deserialization

export function persist(db: AnyOrama) {
    const dbExport = save(db);
    const serialized = JSON.stringify(dbExport);
    return serialized;
}

export function restore(data: string): AnyOrama {
    const db = create({
        schema: {
            __placeholder: 'string'
        }
    });

    const deserialized = JSON.parse(data);

    load(db, deserialized);

    return db;
}

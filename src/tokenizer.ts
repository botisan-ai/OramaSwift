import type { Tokenizer } from "@orama/orama";

import { type BreakIterator, IntlSegmenter } from "./intl-segmenter";

export interface IntlSegmenterTokenizerConfig {
  breakIterator: BreakIterator;
  languages: string[];
}

export function intlSegmenterTokenizer(
  config: IntlSegmenterTokenizerConfig,
): Tokenizer {
  const segmenters = config.languages.map(
    (language) =>
      new IntlSegmenter(config.breakIterator, language, {
        granularity: "word",
      }),
  );

  return {
    language: "",
    normalizationCache: new Map<string, string>(),
    tokenize: (
      raw: string,
      language?: string,
      prop?: string,
      withCache?: boolean,
    ) => {
      // Tokenize the input text using the segmenter
      const words: string[] = [];

      for (const segmenter of segmenters) {
        const segments = segmenter.segment(raw);
        for (const segment of segments) {
          if (segment.isWordLike) {
            words.push(segment.segment);
          }
        }
      }

      return words;
    },
  };
}

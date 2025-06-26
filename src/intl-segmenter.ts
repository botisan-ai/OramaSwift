const BREAK_TYPES = {
  grapheme: 0,
  word: 1,
  sentence: 3,
};

const getSegmentType = (type: number) => {
  if (type < 100) {
    return "none";
  } else if (type >= 100 && type < 200) {
    return "number";
  } else if (type >= 200 && type < 300) {
    return "word";
  } else if (type >= 300 && type < 400) {
    return "kana";
  } else if (type >= 400 && type < 500) {
    return "ideo";
  }
};

interface BreakIteratorResult {
  start: number;
  end: number;
  type: number;
}

export interface BreakIterator {
  utf8BreakIteratorWithBreakTypeLocaleTextToBreak: (
    breakType: number,
    locale: string,
    textToBreak: string,
  ) => BreakIteratorResult[];
}

interface IntlSegmenterOptions {
  granularity?: "grapheme" | "word" | "sentence";
}

interface SegmentResult {
  segment: string;
  index: number;
  isWordLike?: boolean;
  breakType?: string;
}

export class IntlSegmenter {
  constructor(
    private readonly breakIterator: BreakIterator,
    private readonly locale: string,
    private readonly options: IntlSegmenterOptions = {
      granularity: "grapheme",
    },
  ) {}

  segment(input: string): SegmentResult[] {
    const locale = this.locale;
    const granularity = this.options.granularity || "grapheme";

    const result = this.breakIterator.utf8BreakIteratorWithBreakTypeLocaleTextToBreak(
      BREAK_TYPES[granularity],
      locale,
      input,
    );

    let index = 0;

    const segments = result.map(({ start, end, type }) => {
      const segment = input.slice(start, end);
      const returnValue = {
        segment,
        index,
        isWordLike:
          granularity === "word" ? getSegmentType(type) !== "none" : undefined,
        breakType: granularity === "word" ? getSegmentType(type) : undefined,
      };

      index += segment.length;
      return returnValue;
    });

    return segments;
  }
}

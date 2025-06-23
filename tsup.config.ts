import { defineConfig } from 'tsup'

export default defineConfig((options) => ({
  entry: ['src/index.ts'],
  format: ['iife'],
  outDir: 'Sources/OramaSwift/Resources',
  minify: false,
  splitting: false,
  sourcemap: true,
  clean: true,
  dts: true,
  globalName: 'orama',
}));

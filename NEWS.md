# DoubleFloats release notes

## 2.0.0 (in development)

Requires Julia 1.12.

### Changed behaviour

Each entry is one line of the upgrade guide: what changed, and what to do.

- `Double64(hi, lo)`, `Double32(hi, lo)`, and `Double16(hi, lo)` return a
  normalized pair: the high word is `hi + lo` rounded to nearest. Before,
  the two words were stored as given, and a pair that was not normalized
  compared and printed wrongly. A pair that is already normalized is
  returned unchanged, signed zeros included, so code that passes the words
  of an existing value sees no difference.
- A pair constructor given a high word that is not finite returns that
  value with a zero low word: `Double64(Inf, NaN)` is `Inf`.
- `parse(Double16, s)` returns a normalized pair. A few values had a low
  word larger than half a unit of the high word; their sum is unchanged.

### Added

- `DoubleFloats.isnormalized(x)`.

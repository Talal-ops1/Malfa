# Edge Function dependencies

- `@supabase/supabase-js` `2.112.4` — exact version in every function.
- `jpeg-js` `0.4.4` — exact version used only by `upload-cover` to decode the
  submitted JPEG into pixels and encode a fresh metadata-free JPEG.

OSV checks on 2026-08-30 returned no known vulnerabilities for either exact
package version. No Edge Function dependency uses a floating major range.

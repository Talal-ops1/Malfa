# Browser dependencies

- `@supabase/supabase-js` `2.112.4`
  - Vendored file: `supabase-2.112.4.min.js`
  - Source: `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2.112.4/dist/umd/supabase.min.js`
  - SHA-256: `9a8142ffedb319a3ac0d4a8a123c9c2f7ffdb0e1e86cd9553889911b647175f6`

The production HTML loads this local, exact-version bundle. No floating CDN
dependency or private server key is shipped to the browser.

## Vulnerability audit — 2026-08-30

The official npm package metadata pins every bundled Supabase module to the
same exact release: `supabase-js`, `auth-js`, `storage-js`, `realtime-js`,
`functions-js`, and `postgrest-js` at `2.112.4`. An OSV batch query for all six
exact package/version pairs returned no known vulnerabilities (including no
high or critical findings). The npm registry also publishes signed provenance
for the top-level package and integrity
`sha512-UiCX1udlFY1fQQrO7Z3GU7obQsju0w5Vk9mOOwalfo/+Gy+tahWVenSSuu5E/GTy/q//HxvGv2IrCdW66/61kw==`.

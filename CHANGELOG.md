# Changelog

## 1.5.0 - 2026-08-26

- Add persistent CAD model upload and read endpoints for post embeds.
- Let published CAD previews reference stable model ids instead of pruneable Discourse upload short URLs.
- Keep model responses inline for viewer fetches without rendering a download link in posts.

## 1.4.0 - 2026-08-26

- Add CAD Viewer runtime `v044`.
- Support DXF local preview in the Discourse `/viewer` runtime.
- Keep the existing `v043` runtime for compatibility with older theme component versions.

## 1.3.0 - 2026-08-24

- Serve the CAD Viewer bundle and OCCT/Draco decoders from versioned plugin `public/` URLs.
- Remove the Viewer runtime's dependency on pruneable Discourse theme-upload URLs.

## 1.2.0 - 2026-08-21

- Add editable Title, Description and Keywords site settings for Typing and 3D Viewer.
- Keep localized client/server defaults when an override is left blank.

## 1.1.0 - 2026-08-21

- Add localized route titles for Typing and 3D Viewer.
- Add route-specific description, keywords and canonical metadata for direct loads and SPA navigation.

## 1.0.0 - 2026-08-21

- Register refresh-safe `/typing` and `/viewer` Rails shell routes.
- Add Ember route map entries for `moaclab-typing` and `moaclab-viewer`.
- Add placeholder route templates for the Typing and CAD Viewer Theme Components to mount into.
- Add `moaclab_tools_enabled` site setting.
- Replace the older single-purpose `discourse-moaclab-typing-route` plugin.

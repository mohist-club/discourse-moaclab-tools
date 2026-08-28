# Changelog

## 1.5.11 - 2026-08-28

- Add CAD Viewer runtime `v055`.
- Add a DWG-to-DXF fallback path when direct DWG database reading returns no data.
- Improve the unsupported DWG error message for files LibreDWG still cannot decode.

## 1.5.10 - 2026-08-28

- Add CAD Viewer runtime `v054`.
- Remove LibreDWG's dynamic JavaScript invoker generation so DWG loading can run under Discourse CSP without `unsafe-eval`.

## 1.5.9 - 2026-08-28

- Add CAD Viewer runtime `v053`.
- Show supported file formats in the viewer header.
- Show the active uploaded file name inside the canvas.

## 1.5.8 - 2026-08-28

- Add CAD Viewer runtime `v052`.
- Add DWG persistent model upload/read support.
- Bundle LibreDWG WebAssembly runtime for browser-side DWG preview of common model-space 2D entities.

## 1.5.7 - 2026-08-26

- Add CAD Viewer runtime `v051`.
- Make the 3D canvas background theme-aware instead of hard-coding a near-white canvas: light mode uses a soft neutral grey, while dark mode uses a dark neutral surface.
- Watch Discourse theme attribute changes so the canvas background follows light/dark theme switches.

## 1.5.6 - 2026-08-26

- Add CAD Viewer runtime `v050`.
- Improve the default online preview composition with a less aggressive camera angle, more breathing room around thin keyboard parts, lower exposure, stronger readable shadow contrast, and less washed-out imported STEP / IGES materials.

## 1.5.5 - 2026-08-26

- Add CAD Viewer runtime `v049`.
- Fix the explode control for imported STEP / IGES models by calculating each part's explode vector from its actual bounding-box center relative to the whole model center.

## 1.5.4 - 2026-08-26

- Add CAD Viewer runtime `v048`.
- Tune the CAD preview renderer toward Autodesk-style appearance settings: shadow rendering, high pixel ratio, sharp-highlight lighting, light neutral canvas, and less overly-metallic imported STEP/IGES materials.
- Keep mesh wireframe disabled by default to avoid reintroducing the unwanted reference/grid-line look on thin models.

## 1.5.3 - 2026-08-26

- Add CAD Viewer runtime `v047`.
- Improve CAD preview readability with a light Autodesk-like canvas, higher pixel ratio, brighter multi-direction lighting, and better default front-facing views for thin parts.

## 1.5.2 - 2026-08-26

- Add CAD Viewer runtime `v046`.
- Remove the scene reference grid from embedded CAD previews for a cleaner model-only view.

## 1.5.1 - 2026-08-26

- Add CAD Viewer runtime `v045`.
- Default embedded model previews to solid mode, stop autorotation after load, and refit after the model is parsed.
- Surface an explicit error for empty parsed geometry and a warning for extremely thin geometry.

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

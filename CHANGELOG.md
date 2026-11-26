# Changelog

## 1.6.1 - 2026-10-22

- 图纸列表同时收录 `drawings` 标签下的公开话题，同一话题不重复展示。
  Include public topics tagged `drawings` alongside existing CAD references without duplicates.
- 自动识别标签话题首帖的本站 CAD 附件；没有可预览附件的条目仅显示详情入口。
  Detect supported native CAD attachments in tagged first posts; topics without previewable files link to their details only.
- 保留权限过滤、搜索、格式筛选、分页与明确的不收录设置。
  Preserve visibility checks, search, format filtering, pagination and explicit listing opt-outs.
- 附件预览遵循登录后下载限制，忽略不存在或安全附件，不绕过站点权限。
  Respect login-required downloads and exclude missing or secure attachments without bypassing access controls.

## 1.6.0 - 2026-10-22

- `/viewer` 默认显示公开图纸列表，支持搜索、格式筛选、分页、帖子详情与模型预览。
  `/viewer` now opens the public drawing library with search, format filters, pagination, topic details and model previews.
- 图纸随首帖维护并自动收录，排除私信、受限类别、隐藏和删除的内容。
  Drawings follow their source topics automatically; private messages, restricted categories, hidden and deleted content are excluded.
- 支持独立本地预览和自愿分享流程，保留原生发帖确认；新增 GLB、GLTF、STL 和 OBJ 存储支持。
  Keep local previews separate from opt-in sharing through the native composer; add GLB, GLTF, STL and OBJ persistence.

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

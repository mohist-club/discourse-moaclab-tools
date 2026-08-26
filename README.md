# Discourse Moaclab Tools

Moaclab Discourse companion plugin for the Typing and CAD Viewer theme components.

It registers first-class Discourse pages:

- `/typing` -> Ember route `moaclab-typing`
- `/viewer` -> Ember route `moaclab-viewer`

The plugin provides Rails shell routes, Ember route definitions, refresh-safe URL handling, and the versioned CAD Viewer runtime under `/plugins/discourse-moaclab-tools/viewer/`. The Typing and CAD Viewer interfaces remain in their separate Discourse Theme Components.

The CAD runtime lives in the plugin rather than Theme Component uploads. Discourse can prune or replace upload-backed asset URLs, while plugin `public/` assets keep a stable path across browsers and caches. Rebuild this plugin before installing a CAD Viewer component that references a newer runtime version. Version `1.5.4` publishes Viewer runtime `v048` with DXF local preview support, embedded-preview fit fixes, clean model-only previews, Autodesk-like preview lighting, shadow rendering, clearer material response, and persistent CAD model endpoints for post embeds.

## CAD Model Embed Storage

The CAD Viewer Theme Component posts model embeds by uploading the model file to this plugin first, then inserting a shortcode such as:

```md
[moaclab-3d id="0123456789abcdef" ext="step" title="example.step"]
```

The model file is served back through `/moaclab-cad/models/:id` with `Content-Disposition: inline`, so anonymous readers can preview public topic embeds from another browser without needing the uploader's local file. The post still uses a normal Discourse image upload for the preview screenshot.

## Route TDK

Typing and Viewer route metadata is owned by this plugin because it owns the real `/typing` and `/viewer` routes.

- Browser title, description and keywords: `config/locales/client.en.yml` and `config/locales/client.zh_CN.yml`
- Direct-load/crawler title, description and keywords: `config/locales/server.en.yml` and `config/locales/server.zh_CN.yml`
- Client metadata lifecycle: `assets/javascripts/discourse/lib/moaclab-tool-meta.js`
- Server metadata hooks: `plugin.rb`

Keep the client and server strings aligned when editing TDK. Theme Component interface labels in `moaclab-typing` and `moaclab-cad-viewer` do not control page metadata.

Administrators can override the localized defaults under **Admin → Plugins → Moaclab Tools → Settings** using the six `moaclab_*_meta_*` fields. Leaving a field empty keeps the language-pack value.

## Why this plugin exists

Theme Components alone cannot create server-backed Discourse routes. Earlier `/?typing` and `/?viewer` query-parameter URLs stayed inside the Discovery route, which could leave Home, category, or tool sidebar entries selected at the same time.

Real routes let Discourse handle page teardown, direct refresh, browser back/forward, and current-route sidebar state correctly.

## Install With app.yml

Add this repository to `/var/discourse/containers/app.yml`:

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/mohist-club/discourse-moaclab-tools.git
```

Then rebuild the Discourse app container:

```sh
cd /var/discourse
./launcher rebuild app
```

If the final GitHub repository owner or name changes, replace the clone URL above before release. Current proposed target is `mohist-club/discourse-moaclab-tools`; do not publish or tag it until the owner and permissions are confirmed.

## Theme Components

After the plugin rebuild finishes, install or update these Theme Components from the Discourse admin UI:

- `moaclab-typing.zip`
- `moaclab-cad-viewer.zip`

Enable each component on the active theme. The components provide UI, browser storage, and sidebar links; this plugin makes `/typing` and `/viewer` true Discourse routes and serves the CAD Viewer runtime.

## Replacing The Old Route Plugin

If `discourse-moaclab-typing-route` is installed, remove it from `app.yml` before adding this plugin. The old plugin only registered the `/typing` Rails shell and will conflict with this plugin.

## Release Process

1. Update `# version:` in `plugin.rb`.
2. Update `CHANGELOG.md`.
3. Run the request specs in a Discourse development/test environment.
4. Commit the standalone plugin root.
5. Push to the confirmed GitHub repository default branch.
6. Create a signed or annotated tag such as `v1.0.0`.
7. Publish a GitHub Release with the changelog entry and the app.yml clone URL.

Discourse production installs should clone from GitHub instead of uploading this plugin as a Theme Component.

## Moaclab Production Boundary

This repository is only for the Discourse plugin. The main `moaclab.com` website continues to publish through the Moaclab home repository, GitHub Actions, the `hostinger` branch, and Hostinger. Do not bind `moaclab.com` to Sites for this plugin release.

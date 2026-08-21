# Discourse Moaclab Tools

Moaclab Discourse companion plugin for the Typing and CAD Viewer theme components.

It registers first-class Discourse pages:

- `/typing` -> Ember route `moaclab-typing`
- `/viewer` -> Ember route `moaclab-viewer`

The plugin only provides Rails shell routes, Ember route definitions, and refresh-safe URL handling. The Typing and CAD Viewer interfaces remain in their separate Discourse Theme Components.

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

Enable each component on the active theme. The components provide UI, local assets, browser storage, and sidebar links; this plugin only makes `/typing` and `/viewer` true Discourse routes.

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

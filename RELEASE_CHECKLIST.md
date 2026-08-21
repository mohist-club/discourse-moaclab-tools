# Release Checklist

Use this directory as the root of the standalone GitHub repository.

## Target Repository

- Proposed owner/name: `mohist-club/discourse-moaclab-tools`
- Clone URL for Discourse `app.yml`: `https://github.com/mohist-club/discourse-moaclab-tools.git`
- Status: pending user confirmation and valid GitHub authentication

Do not create the repository, push, tag, or publish a Release until the owner, repository name, visibility, and GitHub permissions are confirmed.

## First Publish

1. Confirm the target GitHub repository and visibility.
2. Confirm `gh auth status` is valid for an account with access to the target owner.
3. Initialize or copy this plugin root into the standalone repository.
4. Commit all plugin files from this directory.
5. Push the default branch.
6. Tag `v1.0.0`.
7. Create a GitHub Release using the `CHANGELOG.md` entry.
8. Test the app.yml clone URL on a staging Discourse rebuild.

## Expected Repository Contents

- `plugin.rb`
- `config/settings.yml`
- `config/locales/server.en.yml`
- `config/locales/server.zh_CN.yml`
- `assets/javascripts/discourse/moaclab-tools-route-map.js`
- `assets/javascripts/discourse/routes/moaclab-typing.js`
- `assets/javascripts/discourse/routes/moaclab-viewer.js`
- `assets/javascripts/discourse/templates/moaclab-typing.gjs`
- `assets/javascripts/discourse/templates/moaclab-viewer.gjs`
- `spec/requests/tool_routes_spec.rb`
- `README.md`
- `CHANGELOG.md`
- `RELEASE_CHECKLIST.md`

## app.yml Snippet

```yml
hooks:
  after_code:
    - exec:
        cd: $home/plugins
        cmd:
          - git clone https://github.com/mohist-club/discourse-moaclab-tools.git
```

## Theme Component Release Pairing

Publish or archive the matching Theme Component packages alongside the plugin Release notes:

- `moaclab-typing.zip`
- `moaclab-cad-viewer.zip`

Keep `discourse-moaclab-tools.zip` only as a convenience archive; the production install path should be the GitHub clone URL.

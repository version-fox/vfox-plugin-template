# vfox-plugin-template

A [vfox plugin](https://vfox.dev/plugins/create/howto.html) template with shared
validation and publishing workflows.

## Usage

1. [Generate a repository](https://github.com/version-fox/vfox-plugin-template/generate)
   from this template.
2. Configure the plugin name, homepage, description and other fields in
   [metadata.lua](metadata.lua). Set `PLUGIN.manifestUrl` to your own repository's
   `releases/download/manifest/manifest.json` address, or remove it if your plugin
   will be distributed through the global registry.
3. Implement the hooks using the [plugin development guide](https://vfox.dev/plugins/create/howto.html).

Keep runtime resources under `lib/`. Shared checks validate metadata, required hook
files and Lua syntax and build the same package used for publishing. They do not
run lifecycle hooks or install SDKs. See the [package contract](https://github.com/version-fox/plugin-manifest-action#插件包与检查范围).

## Lua checks and formatting

Use [StyLua 2.5.2](https://github.com/JohnnyMorganz/StyLua/releases/tag/v2.5.2)
with the included `stylua.toml` configuration:

```shell
stylua .
stylua --check .
```

The shared PR check validates metadata, required hooks and Lua 5.1 syntax.
Repositories with `stylua.toml` also receive a read-only format check after the
shared tool release containing that check is published. Existing plugins can opt
in by adding this configuration and formatting their Lua files together.
Plugin behavior tests remain separate from syntax and style checks.

## Publish a plugin

Merge your changes into the default branch, then open **Actions → Plugin → Run
workflow**. Select the default branch and enter a stable version such as `0.1.0`,
without `v`. The workflow updates `PLUGIN.version`, commits the change, creates the
tag, packages the plugin and publishes its Release and manifest.

You can also use GitHub CLI:

```bash
gh workflow run publish.yaml --repo OWNER/REPOSITORY --ref main -f version=0.1.0
```

Version-tag pushes remain supported if `metadata.lua` already contains the matching
version. Pull requests only run checks; their titles do not publish releases.
Prerelease version strings are not supported by this initial stable-release flow.

If publication fails, use **Re-run failed jobs** on the original run. Existing
version assets are verified rather than overwritten.

## Shared workflow updates

The caller in [.github/workflows/publish.yaml](.github/workflows/publish.yaml)
references `version-fox/plugin-manifest-action` at `@v1`. Compatible release-tool
updates apply on the next workflow run. Updating that shared tool does not publish
this plugin. No Dependabot configuration or extra release token is required for
this workflow; repository rules must allow its bot to push version commits/tags.

The shared `v1` tag must exist before this caller is enabled. See the
[shared release workflow documentation](https://github.com/version-fox/plugin-manifest-action)
for first-rollout instructions, validation boundaries and failure recovery.

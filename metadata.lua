--- !!! DO NOT EDIT OR RENAME !!!
PLUGIN = {}

--- !!! MUST BE SET !!!
--- Plugin name
PLUGIN.name = "your plugin name"
--- Plugin version
PLUGIN.version = "0.0.3"
--- Plugin homepage
PLUGIN.homepage = "https://github.com/version-fox/vfox-plugin-template"
--- Plugin license, please choose a correct license according to your needs.
PLUGIN.license = "Apache 2.0"
--- Plugin description
PLUGIN.description = "your plugin description"

--- !!! OPTIONAL !!!
--[[
NOTE:
    Minimum compatible vfox version.
    If the plugin is not compatible with the current vfox version,
    vfox will not load the plugin and prompt the user to upgrade vfox.
 --]]
PLUGIN.minRuntimeVersion = "0.3.0"
--[[
NOTE:
    If configured, vfox will check for updates to the plugin at this address,
    otherwise it will check for updates at the global registry.

    If you want use the global registry to distribute your plugin, you can remove this field.

    If you develop a plugin based on the template, which will automatically generate a manifest file by CI,
    you can set this address to the manifest file address, so that the plugin can be updated automatically.

 --]]
PLUGIN.manifestUrl = "https://github.com/version-fox/vfox-plugin-template/releases/download/manifest/manifest.json"
--[[
NOTE:
    Hints shown by `vfox use` and `vfox doctor` (vfox 1.1.0 and later) when a
    command of this SDK is shadowed by another executable earlier in PATH.
    Each entry matches part of the shadowing executable's path
    (case-insensitive) and explains how to hand the command back to vfox.
    Detecting the shadowing itself is done by vfox; there is no need to scan
    PATH in `PreUse` for this. Older vfox versions ignore this field, so
    enabling it needs no `PLUGIN.minRuntimeVersion` bump.
    Uncomment to enable.
    See https://github.com/version-fox/vfox/blob/main/docs/plugins/create/howto.md#shadowhints
 --]]
-- PLUGIN.shadowHints = {
--     {
--         match = "other-manager",
--         message = "The other manager installed its own tool. Remove it so vfox's tool runs.",
--         url = "https://example.com/troubleshooting#shadowed",
--     },
-- }
-- Some things that need user to be attention!
PLUGIN.notes = {}

--- List legacy configuration filenames for determining the specified version of the tool.
--- such as ".node-version", ".nvmrc", etc.
PLUGIN.legacyFilenames = {}

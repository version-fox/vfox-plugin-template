--- Parse the legacy file found by vfox to determine the version of the tool.
--- Useful to extract version numbers from files like JavaScript's package.json or Golangs go.mod.
function PLUGIN:ParseLegacyFile(ctx)
    local filename = ctx.filename
    local filepath = ctx.filepath
    --- You can get a list of installed versions of the current plugin by this function.
    local versions = ctx:getInstalledVersions()

    return {
        version = "xxx"
    }
end

--- This is called before the SDK is uninstalled.
--- @param ctx table Context information
function PLUGIN:PreUninstall(ctx)
    local mainSdkInfo = ctx.main
    local mpath = mainSdkInfo.path
    local mversion = mainSdkInfo.version
    local mname = mainSdkInfo.name
end
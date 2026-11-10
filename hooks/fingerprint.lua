--- Fingerprint reports the facts that identify an installation, so changes made
--- to it after install show up in `vfox use` and `vfox doctor`.
--- This hook is optional: delete this file if your SDK cannot change itself in
--- place and there is nothing to check.
---
--- vfox calls it right after an installation (and after `vfox link`) and keeps
--- the result in the version's receipt. `vfox use` and `vfox doctor` call it
--- again and warn when the facts are no longer the same (fixed with
--- `vfox install --reinstall`).
---
--- The hook runs on every `vfox use`: only read files, never use the network,
--- never start processes, and stay fast (well under 50 ms). Return only what
--- identifies the SDK itself. Changes the user is meant to make, such as
--- global packages, must not be part of it. Return nil when there is nothing
--- to check.
---
--- Older vfox versions never load a hook file they do not know, so adding
--- this file needs no `PLUGIN.minRuntimeVersion` bump.
--- See https://github.com/version-fox/vfox/blob/main/docs/plugins/create/howto.md#fingerprint
local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function read_first_line(path)
    local file = io.open(path, "r")
    if file == nil then
        return nil
    end
    local line = file:read("*l")
    file:close()
    if line == nil then
        return nil
    end
    line = trim(line)
    if line == "" then
        return nil
    end
    return line
end

function PLUGIN:Fingerprint(ctx)
    if type(ctx) ~= "table" then
        return nil
    end
    local path = ctx.path
    if type(path) ~= "string" or path == "" then
        return nil
    end
    -- TODO: point at the file that identifies your SDK. It must change whenever
    -- the SDK changes itself in place, and stay still otherwise. Examples from
    -- real plugins: the git HEAD of a checkout (`flutter upgrade` moves it),
    -- or a launcher jar name in a properties file. A plain VERSION file works
    -- when the SDK ships one.
    local marker = read_first_line(path .. "/VERSION")
    if marker == nil or marker == "" then
        return nil
    end
    return {
        facts = {
            version = marker,
        },
    }
end

--- Detect finds SDKs that are already on the machine and that `vfox` did not
--- install, for `vfox link --detect`. This hook is optional: delete this file
--- if there is nothing sensible to detect.
---
--- Return the SDK directory (the one `EnvKeys` expects as `ctx.path`) and the
--- name to link it under. The name is used as written, so make it something a
--- user would type. It may contain letters, digits, `.`, `_`, `+` and `-`,
--- and must not be `latest`. Entries that are already linked or installed are
--- skipped by `vfox`.
---
--- Older vfox versions never load a hook file they do not know, so adding
--- this file needs no `PLUGIN.minRuntimeVersion` bump.
--- See https://github.com/version-fox/vfox/blob/main/docs/plugins/create/howto.md#detect
local function is_windows()
    return RUNTIME ~= nil and RUNTIME.osType == "windows"
end

local function trim(value)
    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function file_exists(path)
    if type(path) ~= "string" or path == "" then
        return false
    end
    local file = io.open(path, "r")
    if file == nil then
        return false
    end
    file:close()
    return true
end

--- Names that may be linked: letters, digits, `.`, `_`, `+` and `-`,
--- not `latest`.
local function is_linkable(version)
    if type(version) ~= "string" or version == "" or version == "latest" then
        return false
    end
    return version:match("^[A-Za-z0-9][A-Za-z0-9._+%-]*$") ~= nil
end

--- Immediate child names of a directory. Missing or unreadable directories
--- give an empty list, so a manager that is not installed simply contributes
--- no candidates.
local function list_names(dir)
    if type(dir) ~= "string" or dir == "" then
        return {}
    end
    local command
    if is_windows() then
        command = 'dir /b "' .. dir:gsub('"', "") .. '" 2>nul'
    else
        command = 'ls -1 "' .. dir:gsub('"', "") .. '" 2>/dev/null'
    end
    local ok, handle = pcall(io.popen, command)
    if not ok or handle == nil then
        return {}
    end
    local names = {}
    for line in handle:lines() do
        line = trim(line)
        if line ~= "" and line ~= "." and line ~= ".." then
            table.insert(names, line)
        end
    end
    handle:close()
    return names
end

--- The version a directory name carries ("1.2.3", "mytool-1.2.3"), nil when
--- the name carries none.
local function version_from_dirname(name)
    if type(name) ~= "string" then
        return nil
    end
    local version = name:match("(%d+%.%d+%.?%d*[^/\\]*)$") or name:match("^(%d+[^/\\]*)$")
    if version ~= nil and is_linkable(version) then
        return version
    end
    return nil
end

function PLUGIN:Detect(ctx)
    -- TODO: replace `mytool` with the SDK binary your EnvKeys puts on PATH,
    -- and adjust the candidate directories to where that SDK usually lives.
    local binary = "mytool"
    local found = {}
    local seen = {}

    local function is_home(dir)
        if type(dir) ~= "string" or dir == "" then
            return false
        end
        if is_windows() then
            return file_exists(dir .. "\\" .. binary .. ".exe") or file_exists(dir .. "\\bin\\" .. binary .. ".exe")
        end
        return file_exists(dir .. "/bin/" .. binary) or file_exists(dir .. "/" .. binary)
    end

    local function sdk_dir(dir)
        if is_windows() then
            if file_exists(dir .. "\\" .. binary .. ".exe") then
                return dir
            end
            if file_exists(dir .. "\\bin\\" .. binary .. ".exe") then
                return dir .. "\\bin"
            end
            return dir
        end
        if file_exists(dir .. "/bin/" .. binary) then
            return dir
        end
        return dir
    end

    local function add(dir, version, note)
        if type(dir) ~= "string" or dir == "" or seen[dir] then
            return
        end
        if not is_linkable(version) then
            return
        end
        seen[dir] = true
        table.insert(found, { version = version, path = sdk_dir(dir), note = note })
    end

    local function add_home(dir, note)
        if not is_home(dir) then
            return
        end
        -- Prefer a VERSION file next to the SDK when the SDK ships one,
        -- otherwise fall back to the directory name.
        local marker = nil
        local file = io.open(dir .. "/VERSION", "r")
        if file ~= nil then
            marker = file:read("*l")
            file:close()
        end
        local version = nil
        if marker ~= nil then
            version = trim(marker)
        end
        if not is_linkable(version) then
            version = version_from_dirname(dir:match("([^/\\]+)[/\\]*$") or "")
        end
        if is_linkable(version) then
            add(dir, version, note)
        end
    end

    local home = os.getenv("HOME") or os.getenv("USERPROFILE") or ""
    if home ~= "" then
        -- Version managers keep one directory per version here; adapt the
        -- paths to the managers your users have.
        for _, name in ipairs(list_names(home .. "/.local/share/mise/installs/mytool")) do
            add_home(home .. "/.local/share/mise/installs/mytool/" .. name, "installed by mise")
        end
        for _, name in ipairs(list_names(home .. "/.asdf/installs/mytool")) do
            add_home(home .. "/.asdf/installs/mytool/" .. name, "installed by asdf")
        end
    end
    add_home("/usr/local/mytool", "found in /usr/local/mytool")
    add_home("/opt/mytool", "found in /opt/mytool")
    if is_windows() then
        local program_files = os.getenv("ProgramFiles") or "C:\\Program Files"
        add_home(program_files .. "\\MyTool", "installed for all users")
    end

    return found
end

-- Simple config file loading library by SpiderDave
-- the format is:
--
-- keyword = value
-- // This is a comment.  Comments may also be placed at the
-- // end of a line.
--
-- Keywords and values are case-sensitive.
--
-- Keywords and values are automatically trimmed of leading
-- and trailing whitespace.
--
-- Values "true" and "false" are converted to boolean true 
-- and false.
--
-- Values such as "0" or "0xff" are converted to numbers.
local config = {}

function config.load(filename)
    if not util.fileExists(filename) then return end
    local file = io.open(filename, "r")
    for line in file:lines() do
        local k,v
        line = util.split(line,"//")[1]
        if util.trim(line)~="" then
            k=util.trim(util.split(line,"=")[1],1)
            v=util.trim(util.split(line,"=")[2],1)
            -- Attempt to coerce to a boolean or number
            if v=="false" then v=false end
            if v=="true" then v=true end
            v = tonumber(v) or v
            config[k]=v
        end
    end
end

return config
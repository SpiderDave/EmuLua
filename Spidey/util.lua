local util={}

-- Gets the width of text in characters.
-- Accounts for line breaks, but doesn't
-- handle other unprintable characters.
util.textWidth = function(t)
    if #(t or "")==0 then return 0 end
    local lineWidth = 0
    local maxWidth = 0
    
    for i=1,#t do
        local c = t:byte(i)
        if c == 0x0a or c==0xd then
            lineWidth=0
        else
            lineWidth=lineWidth+1
            maxWidth = math.max(maxWidth, lineWidth)
        end
    end
    return maxWidth
end

-- Remove all spaces from a string
util.stripSpaces = function(s)
    return string.gsub(s, "%s", "")
end

util.printf = function(s,...)
    --return io.write(s:format(...))
    return print(s:format(...))
end

function util.fileExists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function util.startsWith(haystack, needle)
    return string.sub(haystack, 1, string.len(needle)) == needle
end

function util.endsWith(haystack, needle)
   return needle=='' or string.sub(haystack,-string.len(needle)) == needle
end

function util.trim(s)
    --if type(s)~="string" then return tostring(s) end
    if not s then return end
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function util.ltrim(s)
  return (s:gsub("^%s*", ""))
end

function util.rtrim(s)
  local n = #s
  while n > 0 and s:find("^%s", n) do n = n - 1 end
  return s:sub(1, n)
end


function util.limitString(s, limit)
    if type(s)~="string" then return s end
    limit = limit or 0x80
    if #s>limit then
        s=s:sub(1,limit).."..."
    end
    return s
end

function util.split(s, delim, max)
  assert (type (delim) == "string" and string.len (delim) > 0,
          "bad delimiter")
  assert(max == nil or max >= 1)
  local start = 1
  local t = {}
  local nSplits = 0
  while true do
    if max then
        if nSplits>= max then break end
    end
    local pos = string.find (s, delim, start, true) -- plain find
    if not pos then
      break
    end
    nSplits=nSplits+1
    table.insert (t, string.sub (s, start, pos - 1))
    start = pos + string.len (delim)
  end
  table.insert (t, string.sub (s, start))
  return t
end

function util.join(a,str)
    local out=""
    for i=1,#a do
        out=out..a[i]
        if i<#a then
            out=out..str
        end
    end
    return out
end

function util.copyTable(t)
  if type(t) ~= 'table' then return t end
  local res = {}
  for k, v in pairs(t) do res[util.copyTable(k)] = util.copyTable(v) end
  return res
end

-- Create a new copy of a table, with keys and values swapped.
function util.flipTable(t)
  if type(t) ~= 'table' then return t end
  local res = {}
  for v, k in pairs(t) do res[util.copyTable(k)] = util.copyTable(v) end
  return res
end


function util.extract(t)
    for k,v in pairs(t) do
        _G[k] = v
    end
end

function util.collision(t1,t2)
  local x1,y1,w1,h1 = t1[1],t1[2],t1[3],t1[4]
  local x2,y2,w2,h2 = t2[1],t2[2],t2[3],t2[4]
  
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

function util.removeLineBreaks(s)
    s = s:gsub(" \n"," ")
    s = s:gsub("\n"," ")
    s = s:gsub("\r","")
    return s
end

function util.getScriptFolder()
    local str = debug.getinfo(2, "S").source:sub(2)
    if util.isWindows() then
        return str:match("(.*[/\\])")
    else
        return str:match("(.*/)")
    end
end

-- Check if we're on Windows
function util.isWindows()
    return (package.config:sub(1,1)=="\\")
end

function util.fixPathSlashes(p)
    if util.isWindows() then
        p = string.gsub(p, "/","\\")
    else
        p = string.gsub(p, "\\","/")
    end
    return p
end


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

util.config = config

function util.writeToFile(file, data)
    local f = io.open(file,"w")
    f:write(data)
    f:close()
end

function util.getFileContents(path)
    local file = io.open(path,"rb")
    if file==nil then return nil end
    io.input(file)
    ret=io.read('*a')
    io.close(file)
    return ret
end

function util.coerceToByte(n)
    return math.min(255, math.max(0, math.floor(n)))
end

function util.sign(number)
    return number > 0 and 1 or (number == 0 and 0 or -1)
end


return util
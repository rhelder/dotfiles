if mode=="draft" then
    Make:htlatex()
else
    Make:htlatex()
    Make:biber()
    Make:htlatex()
    Make:htlatex()
end

local filter = require "make4ht-filter"

-- this variable will hold contents of the CSS file
local csscontent

local function load_css(filename)
  local f = io.open(filename, "r")
  if f then
    local content = f:read("*all")
    f:close()
    -- make sure that the inline CSS don't mess with make4ht DOM filters
    content = "<style type='text/css'>\n<!-- " .. content .. " -->\n</style>"
    return content
  end
end

-- this filter chain will insert CSS
local process = filter{
  function(html, par)
    local cssname = par.input .. ".css"
    -- TeX4ht can produce multiple HTML files. We will load the CSS file contents 
    -- only for the firts time, and cache it for the future use
    csscontent = csscontent or load_css(cssname)
    if csscontent then
      -- we use just string substitution to replace <link ...href="\jobname.css">
      -- the replacement function is used in order to prevent Lua errors caused by % characters in CSS
      html = html:gsub("<link[^>]+" .. cssname .. ".->", function(s) return csscontent  end)
    end
    return html
  end
}

Make:match("html$",  process)

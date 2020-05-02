local http = require "socket.http"
local https = require "ssl.https"
local json = require "json"



local token = ""

function settoken(new_token)
	print(new_token)
	print(token)
	token = new_token
end


function call_api(token,url)
  local data = ""

  local function collect(chunk)
    if chunk ~= nil then
      data = data .. chunk
    end
    return true
  end

  local ok, statusCode, headers, statusText = https.request {
    method = "GET",
    headers = {["Authorization"] = "Token " .. token},
    url = url,
    sink = collect
  }
  print(ok)
  print(statusCode)
  if statusCode == 200 then
    return json.decode(data)
  end
  return nil
end


local function print_array(row)
  for k,v in pairs(row) do
    if k == #row then
      tex.write(v)
      texio.write(v)
    else
      tex.write(v)
      texio.write(v)
      texio.write(" & ")
      tex.sprint(" & ")
    end

  end
  tex.print(" \\\\")
  print(" \\\\")
end


local function print_row(index, json_result)
  local row = {}

  local function iter_db(keys, db)
    for k, a in pairs(keys) do
      if type(a) == "string" then
        a = string.gsub(a,"-","_")
        table.insert(row, db[a])
      elseif type(a) == "table" then
        a[1] = string.gsub(a[1],"-","_")
        iter_db(a[2], db[a[1]])
      end
    end
  end
  iter_db(index, json_result)

  print_array(row)
  --- tex.print(table.concat(row, " & ") .." \\\\")

  texio.write(table.concat(row, " & ") .." \\\\\n")
end


local function print_header(keys)
local header = {}

  local function iter_header(keys,prefix)
    for k, a in pairs(keys) do
      if type(a) == "string" then
        table.insert(header,prefix .. a)
      elseif type(a) == "table" then
        iter_header(a[2],prefix .. a[1] .. " ")
      end
    end
  end
  iter_header(keys,"")
  local tex_header = {}
  for k, v in pairs(header) do
    table.insert(tex_header,"l")
  end
  tex.print("\\begin{longtable}{"..table.concat(tex_header,"|").."}")

  print_array(header)

  tex.print("\\hline")
end



function dump_table(db, rows)
  print_header(rows)
  print("---------------------------")
  for key, value in ipairs(db) do
    print_row(rows, value)
  end
  tex.print(" \\end{longtable} ")
end

function netboxtable(url, cols)
	print(url)
	print(cols)

  nb_data = call_api(token,url)
  dump_table(nb_data["results"],cols)
end


return {settoken = settoken, table=netboxtable }


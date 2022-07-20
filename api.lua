-- Helper functions
function strSplit(delim,str)
    local t = {}

    for substr in string.gmatch(str, "[^".. delim.. "]*") do
        if substr ~= nil and string.len(substr) > 0 then
            table.insert(t,substr)
        end
    end

    return t
end

-- Read body being passed
-- Required for ngx.req.get_body_data()
ngx.req.read_body();
-- Parser for sending JSON back to the client
local cjson = require("cjson")
-- Strip the api/ bit from the request path
local reqPath = ngx.var.uri:gsub("api/", "");
-- Get the request method (POST, GET etc..)
local reqMethod = ngx.var.request_method
-- Parse the body data as JSON
local body = ngx.req.get_body_data() ==
        -- This is like a ternary statement for Lua
        -- It is saying if doesn't exist at least
        -- define as empty object
        nil and {} or cjson.decode(ngx.req.get_body_data());

Api = {}
Api.__index = Api
-- Declare API not yet responded
Api.responded = false;
-- Function for checking input from client
function Api.endpoint(method, path, callback)
    -- If API not already responded
    if Api.responded == false then
        -- check if path matches request
        -- any pattern-less placeholders are replaced by %w+ first
        local pathPattern = "^"..string.gsub(string.gsub(path, "(<[^|]-)>", "%1|%%w+>"), "<%a+|([^>]+)>", "%1").."$"
        if not string.match(reqPath, pathPattern) then
            return false
        end
        -- KeyData = params passed in path
        local keyData = {}
        -- If this endpoint has params
        if string.find(path, "<.->")
        then
            -- Split origin and passed path sections
            local splitPath = strSplit("/", path)
            local splitReqPath = strSplit("/", reqPath)
            -- Iterate over splitPath
            for i, k in pairs(splitPath) do
                -- If chunk contains <something>
                if string.find(k, "<.->")
                then
                    -- Add to keyData
                    keyData[string.match(k, "%<(%a+)%|")] = splitReqPath[i]
                end
            end
        end

        -- return error if method not allowed
        if reqMethod ~= method
        then
            return ngx.say(
                cjson.encode({
                    error=500,
                    message="Method " .. reqMethod .. " not allowed"
                })
            )
        end

        -- Make sure we don't run this again
        Api.responded = true;

        -- return body if all OK
        body.keyData = keyData
        return callback(method, path, body);
    end

    return false;
end


Api.endpoint('POST', '/test',
    function(method, path, body)
        return ngx.say(
            cjson.encode(
                {
                    method=method,
                    path=path,
                    body=body
                }
            )
        );
    end
)

Api.endpoint('GET', '/test/<id|%d+>/<name>',
        function(method, path, body)
            return ngx.say(
                    cjson.encode(
                            {
                                method=method,
                                path=path,
                                body=body,
                            }
                    )
            );
        end
)

Api.endpoint('GET', '/test/<name|%w+>',
        function(method, path, body)
            return ngx.say(
                    cjson.encode(
                            {
                                method=method,
                                path=path,
                                body=body,
                            }
                    )
            );
        end
)

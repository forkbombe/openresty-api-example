# OpenResty API example

OpenResty allows Lua based scripting to create web applications directly on the Nginx webserver.

Your code is running inside the Nginx worker process and therefore does not need to be interpreted or compiled by another service; making it an efficient solution.

This is just a simple example of how you can expose an API endpoint using Nginx (`api.conf`) which passes the request to a Lua script (`api.lua`). 
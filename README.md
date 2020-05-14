# OpenResty API example

OpenResty allows Lua based scripting to create web applications directly on the Nginx webserver.

Your code is running inside the Nginx worker process and therefore does not need to be interpreted or compiled by another service; making it an efficient solution.

This is just a simple example of how you can expose an API endpoint using Nginx (`api.conf`) which passes the request to a Lua script (`api.lua`). 

## Examples
### POST
````
curl --location --request POST 'localhost/api/test' \
--header 'Content-Type: application/json' \
--data-raw '{
	"example" : "true"
}'
````
### Returns (json)
````
{"body":{"example":"true","keyData":{}}}
````

### GET
````
curl --location --request GET 'localhost/api/test/1234/joeb' \
--header 'Content-Type: application/json' \
--data-raw '{
	"example" : "true"
}'
````
## Returns (json)
````
{
    "body": {
        "example": "true",
        "keyData": {
            "name": "joeb",
            "id": "1234"
        }
    }
}
````

## Notice
As far as I am aware Nginx does not provide a variable that outputs the relative path to its main conf file.

As a result, you need to set the absolute path to the lua file in `content_by_lua_file` 

````
// ./api.conf
...
location ~ ^/api(.*)$ {
    default_type 'text/json';
    add_header 'Content-Type' 'application/json';

    ## NOTICE : change to this absolute path of lua file
    content_by_lua_file /ABS/PATH/TO/api.lua;
}
...
````
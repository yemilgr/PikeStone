import ".";

mapping(string:string) server;

mapping inputParams = ([]);

mapping queryParams = ([]);

mapping cookies = ([]);

mapping session = ([]);

object parser;

void create()
{
    server = (mapping(string:string))getenv(); 
    parser = RequestParser(server);
    inputParams = parser->parseParams();
    queryParams = parser->parseQuery();
}

string getPath()
{
    return server["PATH_INFO"] || "/";
}

string getMethod()
{
    return server["REQUEST_METHOD"] || "GET";
}

string getQueryString()
{
    return server["QUERY_STRING"];
}

mixed all() 
{
    return inputParams;
}

mixed input(string|void key, mixed|void value) 
{
    if (zero_type(key)) {
        return inputParams;
    }

    if (zero_type(inputParams[key])) {
        return value;
    }

    return inputParams[key];
}


mixed query(string|void key, mixed|void value) 
{
    if (zero_type(key)) {
        return queryParams;
    }

    if (zero_type(queryParams[key])) {
        return value;
    }

    return queryParams[key];
}

bool has(string key) 
{
    return !zero_type(inputParams[key]);
}

string getBody() {}
import ".";

mapping(string:string) server;

mapping inputParams = ([]);

mapping queryParams = ([]);

mapping cookies = ([]);

mapping session = ([]);

object pathUtil;

object paramParser;

void create()
{
    server = (mapping(string:string))getenv();
    
    pathUtil = PathUtil();
    paramParser = RequestParser(server);
    inputParams = paramParser->parseParams();
    //queryParams = paramParser->parseQuery();
}

string getPath()
{   
    return pathUtil->removeTrailingSlash(server["PATH_INFO"]);
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
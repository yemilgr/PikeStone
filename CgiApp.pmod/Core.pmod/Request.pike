import ".";


mapping(string:string) server;

mapping inputParams = ([]);

mapping queryParams = ([]);

mapping files = ([]);

mapping cookies = ([]);

mapping session = ([]);

object pathUtil = Utils.PathUtil();

object paramParser;

void create()
{
    server = (mapping(string:string))getenv();
    paramParser = Http.RequestParser(server);
    paramParser->parseParams();
    inputParams = paramParser->getInputParams();
    queryParams = paramParser->getQueryParams();
    cookies     = paramParser->getCookieParams();
    //files     = paramParser->getFiles();
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
    return server["QUERY_STRING"] || "";
}

mixed all() 
{
    return inputParams;
}

bool has(string key) 
{
    return !zero_type(inputParams[key]);
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

mixed getCookie(string|void name, mixed|void value)
{
    if (zero_type(name)) {
        return cookies;
    }

    if (zero_type(cookies[name])) {
        return value;
    }

    return cookies[name];
}

void setCookie(string name, string value, array|void extra)
{
    cookies[name] = value;

    string header = sprintf("Set-Cookie: %s=%s; SameSite=Strict; Path=/", name, value);
    
    if (!zero_type(extra)) {
        string extraOptions = ";" + (extra * ";");
        header += extraOptions;
    }
    
    //send cookie
    write(header);
}

string getBody() 
{
    if (server["CONTENT_LENGTH"]) {
        int contentLength = (int)(server["CONTENT_LENGTH"] - " ");
        return Stdio.stdin->read(contentLength);
    }
    
    return "";
}
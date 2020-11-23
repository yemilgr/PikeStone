import ".";

mixed server;

void create()
{
    server = (mapping(string:string))getenv(); 
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

mixed all() {}
mixed input(string|void key, mixed|void val) {}
mixed query(string|void key, mixed|void val) {}
bool has(string key) {}

string getBody() {}
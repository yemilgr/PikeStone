import ".";


private int statusCode = 200;

private string contentType = "text/html";

private array(string) headers;

private string output;

object create()
{
    this_program::headers = ({
        "Pragma: no-cache",
        "Cache-Control: no-store, no-cache, must-revalidate",   // "Cache-Control: max-age=3600 Cache-Control: no-cache, no-store, max-age=0, must-revalidate",
        "X-Content-Type-Options: nosniff",
        "Access-Control-Allow-Origin: *",
        "Access-Control-Allow-Headers: *",
        "Access-Control-Allow-Credentials: true",
        "Access-Control-Allow-Methods: POST, GET, OPTIONS, DELETE, PUT, HEAD, PATCH, TRACE",
        "Access-Control-Max-Age: 1209600"
    });
    
    this_program::output = "";
}

object setStatusCode(int statusCode)
{
    this_program::statusCode = statusCode;
    return this_object();
}

object setContentType(string contentType)
{
    this_program::contentType = contentType;
    return this_object();
}

object setHeader(string header)
{
    this_program::headers += ({header});
    return this_object();
}

object setHeaders(array(string) headers)
{
    this_program::headers += headers;
    return this_object();
}

object html(string html)
{
    setContentType("text/html");
    this_program::output = html;
    return this_object();
}

object json(mapping json)
{
    setContentType("application/json");
    string jsonOutput = Standards.JSON.encode(json);
    this_program::output = jsonOutput;
    return this_object();
}

object notFoundError(string|void error) 
{
    error =  (error) ? error : "Page not found";

    string template = Stdio.read_file(
        sprintf("%s/views/error/%s.html", Application->rootPath, "404")
    );

    this_program::output = replace(template, (["{{content}}": error]));

    setStatusCode(404);
    setContentType("text/html");
    
    return this_object();
}

object accessForbiddenError(string|void error) 
{
    error =  (error) ? error : "Access Forbidden";

    string template = Stdio.read_file(
        sprintf("%s/views/error/%s.html", Application->rootPath, "403")
    );

    this_program::output = replace(template, (["{{content}}": error]));

    setStatusCode(403);
    setContentType("text/html");
    
    return this_object();
}


object applicationError(string|void error) 
{
    error =  (error) ? error : "Error ocurred";

    string template = Stdio.read_file(
        sprintf("%s/views/error/%s.html", Application->rootPath, "500")
    );

    this_program::output = replace(template, (["{{content}}": error]));

    setStatusCode(500);
    setContentType("text/html");
    
    return this_object();
}

void redirect(string path)
{
    write("HTTP/1.0 302 Found\n");
    write(sprintf("Location: %s\n\n", path));
}

//Main function that send headers and response output/redirection
void send(string|void output)
{
    //headers
    foreach(headers;; string header) {
        write(sprintf("%s\n", header));
    }

    write(sprintf("Status: %s\n", (string)this_program::statusCode));
    write(sprintf("Content-Type: %s\n\n", this_program::contentType));
    
    //output
    output = !zero_type(output) ? output : this_program::output;
    
    write(output);
}

import ".";


private int statusCode = 200;

private string contentType = "text/html";

private array(string) headers;

private string output;


object create()
{
    this_program::headers = ({});
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

// object setHeader(string header)
// {
//     this_program::headers += ({header});
//     return this_object();
// }

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

object json(string json)
{
    setContentType("application/json");
    this_program::output = json;
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

//Main function that send headers and response output/redirection
void send(string|void output)
{
    write(sprintf("Status: %s\n", (string)this_program::statusCode));
    write(sprintf("Content-Type: %s\n\n", this_program::contentType));
    
    //headers
    //sendHeaders();

    //output
    output = (output) ? output : this_program::output;
    write(output);
}

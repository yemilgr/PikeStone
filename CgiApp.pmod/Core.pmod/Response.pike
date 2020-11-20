import ".";


void create()
{
    //not implemented
}

void setStatusCode(int code)
{
    write("Status: " + (string)code + "\n");
}

void setContentTypeHtml()
{
    write("Content-Type: text/html \n\n");
}

void sendNotFoundError(string|void message)
{
    setStatusCode(404);
    setContentTypeHtml();
    
    // if(zero_type(message)) {
    message =  message ? message : "You may have mistyped the address or the page may have moved.";
    // }
    
    string template = Stdio.read_file(
        sprintf("%s/views/error/%s.html", Application->rootPath, "404")
    );

    string output = replace(template, (["{{content}}": message]));
    
    write(output);
}

void sendNotAuthorizedError(string|void message)
{

}

void sendOutput(string output)
{
    setStatusCode(200);
    setContentTypeHtml();
    write(output);
}

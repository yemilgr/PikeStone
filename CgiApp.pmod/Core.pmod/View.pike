import ".";

object response;

void create(Response|void response)
{
    this_program::response = response;
}

object render(string view, mapping|void data)
{
    if(!this_program::response) {
        this_program::response = Response();
    }

    string viewPath = sprintf("%s/views/%s.html", Application->rootPath, view);
    
    if (Stdio.exist(viewPath)) {
        string layoutPath = sprintf("%s/views/layout/%s.html", Application->rootPath, "app");
        string layoutHtml = Stdio.read_file(layoutPath);
        string viewHtml = Stdio.read_file(viewPath);

        string output = replace(layoutHtml, (["{{content}}": viewHtml]));
        
        return this_program::response->html(output);
    }
    
    return this_program::response->notFoundError(sprintf("View '%s'  not found", view));
}

string getOutput(string view, mapping|void data)
{
    //return view contents
}
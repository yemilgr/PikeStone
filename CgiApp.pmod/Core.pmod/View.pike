import ".";

object response;

string viewPath;

string templatePath;

void create(Response|void response)
{
    this_program::response = response;
}

object render(string view, mapping|void data)
{
    viewPath = sprintf("%s/views/%s.html", Application->rootPath, view);
    
    if (Stdio.exist(viewPath)) {
        string layoutPath = sprintf("%s/views/layout/%s.html", Application->rootPath, "app");
        string layoutHtml = Stdio.read_file(layoutPath);
        string viewHtml = Stdio.read_file(viewPath);

        //data to pass to the view 
        if (!zero_type(data)) {
            mapping(string:string) replacements = ([]);
            
            foreach (data; string key; mixed value) {
                replacements[sprintf("{{%s}}", key)] = (string)value;
            }

            viewHtml = replace(viewHtml, replacements);
        }

        string output = replace(layoutHtml, (["{{content}}": viewHtml]));
        return response->html(output);
    }
    
    return response->notFoundError(sprintf("View '%s'  not found", view));
}

string getOutput(string view, mapping|void data)
{
    //return view contents
}
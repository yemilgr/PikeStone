import ".";
import "../.";

object request;

object response;

mapping(string:mixed) routes =  ([]);

void create(Request request, Response response)
{
    this_program::request = request;
    this_program::response = response;
}

void get(string path, string|array|function callback)
{
    this_program::routes["GET"] += ([path: callback]);
}

void post(string path, string|array|function callback)
{
    this_program::routes["POST"] += ([path: callback]);
}

// void any(string path, string|array|function callback) 
// {
//     this_program::routes["GET"] += ([path: callback]);
//     this_program::routes["POST"] += ([path: callback]);
// }

void resolve()
{
    string path = request->getPath();
    string method = request->getMethod();
    mixed callback = routes[method][path];

    if (zero_type(callback)) {
        response.sendNotFoundError();
        return;
    }

    //is mapping -> a controller
    if (arrayp(callback)) {
        handleController(callback);
    }

    //is string -> view file
    if (stringp(callback)) {
        handleView(callback);
    }

    //is a callback
    if (functionp(callback)) {
        handleCallback(callback);
    }
}

void handleController(array callback)
{
    string ctrlFile   = callback[0];   //controller
    string ctrlAction = callback[1]; //action

    string classPath = Application->rootPath + "/Controllers.pmod/" + ctrlFile + ".pike";

    //verify controller class exist
    if (!Stdio.exist(classPath)) {
        response.sendNotFoundError(sprintf("Class \"%s.pike\" not found", ctrlFile));
        return;
    }

    mixed error = catch{
        program ctrlClass = compile_file(classPath);
        object controller = ctrlClass(request, response);
        
        //aportacion rbelmonte. with love <3
        if(functionp(controller[ctrlAction] || functionp(controller[ctrlAction]) != UNDEFINED)) {
            handleContent(controller[ctrlAction]());
            return;
        } 
        
        response.sendNotFoundError(
            sprintf("Action '%s' not found in \"%s.pike\"\n%O", ctrlAction, ctrlFile, error)
        );
    };

    if(error) {
        response.sendNotFoundError("Unknown error ocurred");
    }
}

void handleView(string view)
{
    string viewPath = sprintf("%s/views/%s.html", Application->rootPath, view);
    
    if (Stdio.exist(viewPath)) {
        string layoutPath = sprintf("%s/views/layout/%s.html", Application->rootPath, "app");
        string layoutHtml = Stdio.read_file(layoutPath);
        string viewHtml = Stdio.read_file(viewPath);

        string output = replace(layoutHtml, (["{{content}}": viewHtml]));
        
        response.sendOutput(output);
        return;
    }
    
    response.sendNotFoundError();
}

void handleCallback(function callback)
{
    response->sendOutput(callback());
}

void handleContent(string content)
{
    response->sendOutput(content);
}
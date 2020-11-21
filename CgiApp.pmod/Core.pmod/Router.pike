import ".";

// global request object
object request;

//global response object
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

// void only(string methods, string path, string|array|function callback)
// {
//     //todo:
// }

void resolve()
{
    string path = request->getPath();
    string method = request->getMethod();
    mixed callback = routes[method][path];

    if (zero_type(callback)) {
        response->notFoundError("No callback found for matching route");
        response->send();
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
    string ctrlFile   = callback[0]; //controller
    string ctrlAction = callback[1]; //action

    string classPath = Application->rootPath + "/Controllers.pmod/" + ctrlFile + ".pike";

    //verify controller class exist
    if (!Stdio.exist(classPath)) {
        response.notFoundError(sprintf("Class \"%s.pike\" not found", ctrlFile))->send();
        return;
    }

    mixed error = catch {
        program ctrlClass = compile_file(classPath);
        object controller = ctrlClass(request, response);
        
        //aportacion rbelmonte. with love <3
        if (!functionp(controller[ctrlAction]) || functionp(controller[ctrlAction]) == UNDEFINED) {
            response->notFoundError(
                sprintf("Action '%s' not found in '%s.pike'\n%O", ctrlAction, ctrlFile, error)
            )->send();
            return;
        }

        mixed callbackResponse = controller[ctrlAction]();

        // is string
        if (stringp(callbackResponse)) {
            handleContent(callbackResponse);
        }

        //is response object 
        if (objectp(callbackResponse)) {
            handleResponse(callbackResponse);
        }

        return;
    };

    if (error) {
        response->applicationError(sprintf("An error ocurred \n%O", error))->send();
    }
}

void handleResponse(object callbackResponse)
{
    callbackResponse->send();
}

void handleView(string view, mapping|void data)
{
    View(response)->render(view, data)->send();
}

void handleCallback(function callbackFunction)
{
    response->send(callbackFunction());
}

void handleContent(string content)
{
    response->send(content);
}
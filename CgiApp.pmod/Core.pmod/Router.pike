import ".";

// global request object
object request;

//global response object
object response;

object pathUtil = Utils.PathUtil();

mapping(string:mixed) routes =  ([
    "GET":      ([]),
    "POST":     ([]),
    "PUT":      ([]),
    "DELETE":   ([]),
    "OPTIONS":  ([]),
    "HEAD":     ([]),
    "PATCH":    ([]),
]);

void create(Request|void request, Response|void response)
{
    this_program::request = request;
    this_program::response = response;
}

object setRequest(Request request)
{
    this_program::request = request;
    return this_object();
}

object setResponse(Response response)
{
    this_program::response = response;
    return this_object();
}

void get(string path, string|array|function callback)
{
    path = pathUtil->removeTrailingSlash(path);
    this_program::routes["GET"] += ([path: callback]);
}

void post(string path, string|array|function callback)
{
    path = pathUtil->removeTrailingSlash(path);
    this_program::routes["POST"] += ([path: callback]);
}

void put(string path, string|array|function callback)
{
    path = pathUtil->removeTrailingSlash(path);
    this_program::routes["PUT"] += ([path: callback]);
}

void delete(string path, string|array|function callback)
{
    path = pathUtil->removeTrailingSlash(path);
    this_program::routes["DELETE"] += ([path: callback]);
}

void options(string path, string|array|function callback)
{
    path = pathUtil->removeTrailingSlash(path);
    this_program::routes["OPTIONS"] += ([path: callback]);
}

void any(string methods, string path, string|array|function callback) 
{
    path = pathUtil->removeTrailingSlash(path);
    array methodsArr = methods / "|";
    foreach(map(methodsArr, upper_case);; string method) {
        this_program::routes[method] += ([path: callback]);
    }
}

void all(string path, string|array|function callback)
{
    path = pathUtil->removeTrailingSlash(path);
    foreach(({"GET", "POST", "PUT", "DELETE", "OPTIONS"});; string method) {
        this_program::routes[method] += ([path: callback]);
    }
}

void resolve()
{
    mixed error = catch {
        string path     = request->getPath();
        string method   = request->getMethod();
        mixed callback  = resolveCallback(path, method);

        if (zero_type(callback) || callback == UNDEFINED) {
            //check if there is a route with params for this request
            response->notFoundError("No callback found for matching route")->send();
            return;
        }

        //is mapping -> a controller
        if (arrayp(callback["handler"])) {
            handleController(callback["handler"], callback["arguments"]);
        }

        //is a callback
        if (functionp(callback["handler"])) {
            handleCallback(callback["handler"], callback["arguments"]);
        }
        
        //is string -> view file
        if (stringp(callback["handler"])) {
            handleView(callback["handler"]);
        }
    };
   
    if (error) {
        response->applicationError(sprintf("%O", error))->send();
    }
}

mixed resolveCallback(string path, string method) 
{
    mapping callback = ([]);

    if (!zero_type(routes[method][path])) {
        callback["handler"] = routes[method][path];
        callback["arguments"] = ({});
        return callback;
    }
    
    //check if there is a route with params for this request
    foreach (routes[method]; string pathIndex; mixed callbackValue) {
        if (search(pathIndex, "$") != -1) { // this route has params $
            int paramsCount = String.count(pathIndex, "$");
            array params = ({});
            for (int i = 1; i <= paramsCount; i = i+1) {
                string value = sprintf("$%d", i);
                params += ({value});
            }
            string pathRegex = replace(pathIndex, params, "%s");
            array paramValues = array_sscanf(path, pathRegex);

            // check if this routePath has equal number of params 
            // and last param do not contain / char
            if (sizeof(params) == sizeof(paramValues) && 
                 search(paramValues[sizeof(paramValues) - 1], "/") == -1 
                ) {
                callback["handler"] = callbackValue;
                callback["arguments"] = paramValues;
                return callback;
            }
        }
    }

    return UNDEFINED;
}

private void handleController(array callback, array|void arguments)
{
    string ctrlFile   = callback[0]; //controller
    string ctrlAction = sizeof(callback) > 1 ? callback[1] : "index"; //action

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
        
        //pass arguments to controller func
        mixed callbackResponse = controller[ctrlAction](@arguments); 

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
        response->applicationError(sprintf("%O", error))->send();
    }
}

private void handleResponse(object callbackResponse)
{
    callbackResponse->send();
}

private void handleView(string view, mapping|void data)
{
    View(response)->render(view, data)->send();
}

private void handleCallback(function callbackFunction, array|void arguments)
{
    response->send(callbackFunction(@arguments));
}

private void handleContent(string content)
{
    response->send(content);
}
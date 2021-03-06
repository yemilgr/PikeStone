import ".";

// root directory app
constant rootPath = __DIR__ + "/..";

// request object
object request;

// response object
object response;

// router object
object router;

void create()
{
    request = Request();
    response = Response();
}

//Run application
void run()
{
    mixed appRoutes = compile_file(rootPath + "/routes/web.pike");
    
    router = appRoutes()->create();
    
    router->setRequest(request)
        ->setResponse(response)
        ->resolve();
}
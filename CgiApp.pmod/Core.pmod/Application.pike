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
    router = Router(request, response);
}

//Run application
void run()
{
    router->resolve();
}
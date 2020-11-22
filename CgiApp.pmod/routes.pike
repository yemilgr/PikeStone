import ".";

mixed router = Core.Router();

object create() 
{
    // configure app routes
    router->get("/", lambda() {
        return "This output using callback";
    });

    router->get("/home", "home");
    router->get("/contact", ({"ContactController", "index"}));
    router->get("/contact/save", ({"ContactController", "save"}));


    //return the router at the very end!
    return router;
}
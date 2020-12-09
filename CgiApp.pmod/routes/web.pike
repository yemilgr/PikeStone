import "../.";

mixed router = Core.Router();

object create() 
{
    // configure app routes
    router->get("/callback", lambda() {
        return "This output using callback";
    });

    router->get("/", "home");
    router->get("/contact", ({"ContactController", "index"}));
    router->post("/contact/save", ({"ContactController", "save"}));


    //return the router at the very end!
    return router;
}
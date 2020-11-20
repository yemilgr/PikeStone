#!/usr/bin/pike

import ".";

void main() {
    object app = CgiApp.Core.Application();

    app->router->get("/", lambda() {
        return "Hello World!";
    });
    
    app->router->get("/readme", "readme");
    app->router->get("/home", ({"HomeController", "index"}));
    
    //run app
    app->run();
}
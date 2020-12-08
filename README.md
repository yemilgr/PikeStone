# Pike web-cgi micro-framework

[Installation](##Installation)

[Routing](##Routing)

[Request](##Request)

[Response](##Response)

[Controllers](##Controllers)

[Models](##Models)

[Views](##Views)

---

## Installation

1- Download or `git clone` this repo inside your `bin-cgi` root folder.

2- Configure redirect module on the server in order to handle all request in a single cgi file `app.cgi`.

```roxen
/(.*)    /cgi-bin/app.cgi/$1
```
3- Add your app routes in `CgiApp.pmod/routes.pike`

## Routing

### Routes with lambda functions callback

`GET` route to math `/` path that execute an anonymous function 
```pike
router->get("/", lambda() {
    return "Hello world!";
});
```

`POST` with route arguments
```pike
router->post("/hello/$1", lambda(string name) {
    return sprintf("Hello %s", name);
});
```

`POST|GET` to math either 'POST' or 'GET' http method
```pike
router->any("GET|POST", "/any-of-methods", lambda() {
    return "Respond to method get or post";
});
```

Route that match any http method
```pike
router->all("/all-methods", lambda() {
    return "Respond to all http method";
});
```

### Routes that respond a view file

`GET` routes that loads a `home.html` view located in `CgiApp.pmod/views`
Ruta `GET` 
```pike
router->get("/home", "home");
```

`GET` routes that loads a `home/dashboard.html` view located in `CgiApp.pmod/views`
```pike
router->get("/home/dashboard", "home/dashboard");
```

### Routes to Controllers

`GET` route to executes a index function on ContactController Class inside `CgiApp.pmod/Controllers.pmod`
```pike
router->get("/contact", ({"ContactController", "index"}));
```

`POST` route to same path 
```pike
router->post("/contact", ({"ContactController", "save"}));
```

`POST|PUT` with arguments
```pike
router->any("POST|PUT", "/post/$1/comment/$2", ({"PostController", "addComment"}));
```

## Request 

## Response

## Controllers 

## Models 

## Views


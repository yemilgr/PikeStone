# Pike web-cgi micro-framework

[Installation](#Installation)

[Routing](#Routing)

[Request](#Request)

[Response](#Response)

[Controllers](#Controllers)

[Models](#Models)

[Views](#Views)

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
The request class is the one in charge of handling the request input and data.

### Request functions

`string getMethod()` return the http request method
```pike
//"GET", "POST", "PUT", "DELETE" etc
request()->getMethod(); 
```

`string getQueryString()` return the query string
```pike
//"GET", "POST", "PUT", "DELETE" etc
request()->getQueryString(); 
```

`mapping all()` return an indexed mappping of all input parameters in the request 
```pike
request()->all();
```

`bool has(string key)` checks if a parameter exists in the request 
```pike
request()->has("name"); 
```

`mixed input(string|void key, mixed|void value)` return the value of key, if key is not present return value
```pike
request()->input("name", "Jhon Doe"); 
```

`mixed query(string|void key, mixed|void value)` return the value of key only on the QueryString, if key is not present return value
```pike
request()->query("name", "Jhon Doe"); 
```

`mixed getCookie(string|void name, mixed|void value)` return the cookie value if cookie exist, otherwise return the default value
```pike
request()->getCookie("lastAccess", "31 Dic 2020");
```

`void setCookie(string name, string value, array|void extra)` sets a cookie [Set-Cookie Docs](https://developer.mozilla.org/es/docs/Web/HTTP/Headers/Set-Cookie)
```pike
request()->setCookie("user", "Yemil", ({
    "Secure",
    "SameSite=Strict",
    "HttpOnly"
}));
```

`string getBody()` return the raw body of the request.
```pike
request()->getBody();
```

## Response

## Controllers 

## Models 

## Views


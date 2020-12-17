# Pike web-cgi micro-framework
![Pike Stone](https://media0.giphy.com/media/qN9x0UIc0Rhg4/giphy.gif "PikeStone Dino")

[1 QuickStart](#1-QuickStart)
    
[2 Routing](#2-Routing)

[3 Request](#3-Request)

- [3.1 Request functions](#31-Request-Functions)
- [3.2 Input Validation](#32-Input-Validation)

[4 Response](#4-Response)

- [4.1 Response functions](#4.1-Response-Functions)

[5 Controllers](#5-Controllers)

- [5.1 Controller functions](#4.1-Controller-Functions)

[6 Models](#6-Models)

- [6.1 Request functions](#61-Model-Definition)
- [6.2 Input Validation](#62-Common-Functions)

[7 Views](#7-Views)

[8 Libraries](#8-Libraries)
- [8.1 Validation](#81-Validation)
- [8.2 QueryBuilder](#82-QueryBuilder)

---

## 1. QuickStart

- Download or `git clone` this repo inside your `bin-cgi` root folder.

- Configure redirect module on the server in order to handle all request in a single cgi file `app.cgi`

    ```roxen
    /(.*)    /cgi-bin/app.cgi/$1
    ```
- Add your app routes in `CgiApp.pmod/routes/web.pike`

## 2. Routing

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

## 3. Request 
The request class is in charge of handling the request input and data.

### 3.1 Request functions

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

`void setCookie(string name, string value, array|void extra)` sets a cookie [Set-Cookie Docs](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie)
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




### 3.2 Input Validation

## 4. Response

The controller class is in charge of creating a respond to send to browser or client who send a request. 

### 4.1 Response functions

`object setStatusCode(int statusCode)` sets the status code of the response.
```pike
response()->setStatusCode(201);
```

`object setContentType(string contentType)` sets the content type of the response.
```pike
response()->setContentType("application/json");
response()->setContentType("text/plain");
```

`object setHeader(string header)` set a response header. [HTTP Headers Docs](https://developer.cdn.mozilla.net/en-US/docs/Web/HTTP/Headers)
```pike
response->setHeader("Content-Type: application/json");
response->setHeader("Connection: Keep-Alive");
response->setHeader("Keep-Alive: timeout=5, max=997");
```

`object setHeaders(array(string) headers)` sets an array of header values
```pike
response->setHeaders(({
    "Content-Type: application/json",
    "Connection: Keep-Alive",
}));
```

`object html(string html)` send a html respond to the client
```pike
return response->html("<h1>Hello world</h1>");
```

`object json(mapping json)` send a json respond to the client
```pike
return response->json(([
    "code": 200,
    "message": "Hello World"
]));
```

`void redirect(string path)` send a 302 redirecting response 
```pike
return response->redirect("https://google.com");
```

`object notFoundError(string|void error)` send a 404 Not Found response
```pike
return response()->notFoundError("The user does not exist");
```

`object accessForbiddenError(string|void error)` send a 403 Forbidden response
```pike
return response()->accessForbiddenError("Your are not authorized");
```

`object applicationError(string|void error)` 
```pike
return response()->applicationError("And unknown error occurred. Please try again in a few minutes");
```

## 5. Controllers 
Controllers are the classes that handles business-related tasks, and should be placed inside the `Controllers.pmod` folder.

Every controller must inherit the base `Core.Controller.pike` class.

Function defined in controllers are called `actions`. 

Every action must return a string or a response instance.

### 5.1 Controller functions 
Common functions defined in Base `Controller.pike` class.

```pike
// return a instance of Request Class
request()

// return a instance of Response Class
response()

//return a instance of Input Validator Class
validator()

//return a instance of Views Class
view()
```

Example controller `HomeController.pike`
```pike
import "../.";

inherit Core.Controller;

mixed index()
{
    string name = request()->input("name");

    return sprintf("Hello %s, you are in home", name);
}

mixed mustBeSomeone()
{
    mixed validator = validator();

    // input 'name' must be required and a min length of 5 characters
    mapping validData = validator->validate([(
        "name": "required|min_length:5"
    )]);

    if (validator->hasErrors()) {
         mixed errors = validator->errors();
         return sprintf("<pre>Errors: \n\n %O</pre>", errors);    
    }

    return sprintf("Hello %s, you are in home", validData["name"]);
}

mixed hello(string name)
{
    return view()->render("hello", ([
        "name": name
    ]));
}

mixed helloJson(string name)
{
    return response()->json(([
        "success": true,
        "message": "Hello " + name
    ]));
}
```


## 6. Models 
Models are classes that handles data manipulation. 
In other words, the model is responsible for managing the data of the application. It receives user input from the controller.

Every model must inherit the base `Core.Model.pike` class.

### 6.1 Model definition

```pike 
import "../.";

inherit Core.Model;

string table = "users"; // defines the table associated with this model Class
string pk    = "id";    // defines the primary key of this Class

```

### 6.2 Common functions

Consider a `UsersController.pike`
```pike 
import "../.";
inherit Core.Controller;

object userModel = Models.UserModel();

mixed index()
{
    // SELECT QUERIES

    // raw query
    mixed result = userModel->query("select * from users where id in (1, 2, 3)");

    // find user by primary key
    mixed user = userModel->find(100);
    mixed users = userModel->find(({100, 999}));

    // find a user by a custom column
    user = userModel->findBy("email", "yemilgr@pikestone.com");
    users = userModel->findAll();

    // INSERT QUERIES

    mixed result = userModel->insert(([
        "email": "yemilgr@pikestone.com",
        "password": "secret"
    ]));

    // UPDATE QUERIES
    mapping data = ([
        "password": "new-secret"
    ]);

    userModel->update(1, data);
    userModel->update(({1, 2}), data);
    userModel->updateWhere("email", "yemilgr@pikestone.com", data);

    // DETELE QUERY
    userModel->delete(1);
    userModel->delete(({1, 2}));
    userModel->deleteWhere("email", "yemilgr@pikestone.com");
}

```

## 7. Views
A view is simply a web page, or a page fragment, like a header, footer, sidebar, etc, that produces a response for the browser.

Views are placed in `views` folder they are never called directly, they must be loaded by a controller.

A base template is define in `views/layout/app.html` and will be used to render the aps views inside it.

Consider this UserController class.

```pike 
import "../.";
inherit Core.Controller;

mixed newUser() 
{
    // render the view template located in view/user/newForm.html
    return view()->render("user/newForm");
}

mixed showDetails() 
{
    mixed user = User();

    // render the view template located in view/user/details.html
    return view()->render("user/details", ([
        "userName": user->name,
        "userEmail": user->email
    ]));
}
```

Example Template locate at `view/user/details`
```html
<h1>User Details</h1>
<p>Name: {{userName}}</p>
<p>Email: {{userEmail}}</p>
```

## 8. Libraries

### 8.1 Validation

### 8.2 QueryBuilder
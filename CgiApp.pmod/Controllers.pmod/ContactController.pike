import "../.";

inherit Core.Controller;

mixed index()
{
    return view()->render("contact", ([
        "title": "Contact page",
        "subtitle": "My subtitle page"
    ]));
}

mixed save()
{
    return "Contact save successfully" + req()->getQueryString();
}
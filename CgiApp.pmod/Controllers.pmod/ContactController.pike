import "../.";

inherit Core.Controller;



string index()
{
    return "handling contact " + request->getQueryString();
}
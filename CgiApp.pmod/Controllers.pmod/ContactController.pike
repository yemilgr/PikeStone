import "../.";

inherit Core.Controller;


mixed index()
{
    return view()->render("contact");

    // return response()->html();
}
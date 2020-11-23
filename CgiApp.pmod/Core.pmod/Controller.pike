import ".";

private object request;

private object response;

private object viewLayout;

void create (Request|void request, Response|void response)
{
    this_program::request = request;
    this_program::response = response;
    this_program::viewLayout = View(response);
}

object req()
{
    return this_program::request;
}

object res()
{
    return this_program::response;
}

object view()
{
    return this_program::viewLayout;
}


import ".";

object request;

object response;

void create (Request|void request, Response|void response)
{
    this_program::request = request;
    this_program::response = response;
}

object req()
{
    return this_program::request;
}

object res()
{
    return this_program::response;
}

object validator()
{
    return Http.Validator(request->all());
}

object view()
{
    return View(response);
}
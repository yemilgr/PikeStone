import ".";

object request;

object response;

object view;

void create (Request|void request, Response|void response)
{
    this_program::request = request;
    this_program::response = response;
    this_program::view = View();
}
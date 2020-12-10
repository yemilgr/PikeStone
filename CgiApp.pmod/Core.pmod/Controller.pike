import ".";

object requestInstance;

object responseInstance;

void create (Request|void request, Response|void response)
{
    this_program::requestInstance = request;
    this_program::responseInstance = response;
}

object reqquest()
{
    return this_program::requestInstance;
}

object response()
{
    return this_program::responseInstance;
}

object validator()
{
    return Http.Validator(requestInstance->all());
}

object view()
{
    return View(responseInstance);
}
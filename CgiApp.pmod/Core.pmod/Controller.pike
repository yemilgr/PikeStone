import ".";

object request;

object response;

void create (Request|void request, Response|void response)
{
    this_program::request = request;
    this_program::response = response;
}

string get(string|void key)
{
    //si key esta vacia se devuelve un mapping de todo el array que hay en get
    //si key existe se devuelve su valor 
    return "GET";
}

string post(string|void key)
{
    //si key esta vacia se devuelve un mapping de todo el array que hay en post
    //si key existe se devuelve su valor 
    return "POST";
}
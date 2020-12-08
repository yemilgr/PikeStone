// Connection Class 
import ".";
#include "../../config/database.h";

inherit Sql.Sql;

object create(string|void connection)
{
    string conn = zero_type(connection) ? "default" : connection;
    mapping connectionParams = CONNECTION[conn];

    ::create(
        connectionParams["host"], 
        connectionParams["database"], 
        connectionParams["user"], 
        connectionParams["password"],
        connectionParams["options"]
    );
    
    return this_object();
}
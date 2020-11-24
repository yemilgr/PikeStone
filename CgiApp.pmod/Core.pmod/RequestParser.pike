import ".";

constant ARRAY_SUFFIX = "__";

constant VAR_PREFIX = "VAR_";

mapping server;

void create(mapping server)
{
    this_program::server = server;
}

mapping parseParams()
{
    mapping params = ([]);

    if (zero_type(server["VARIABLES"])) {
        return params;
    }    
    
    array vars = server["VARIABLES"] / " ";

    foreach (vars, string var) {
        //is array
        if (has_suffix(var, ARRAY_SUFFIX)) {
            string varName = replace(var, ARRAY_SUFFIX, "");
            params[varName] = server[VAR_PREFIX + var] / "#";

        }
        else {
            params[var] = server[VAR_PREFIX + var];
        }
    }

    return params;
}


mapping parseQuery()
{
    mapping query = ([]);

    if (zero_type(server["VARIABLES"]) || zero_type(server["QUERY_STRING"])) {
        return query;
    }

    string decodedQuery = Protocols.HTTP.uri_decode(server["QUERY_STRING"]); 
    array vars =  server["VARIABLES"] / " ";
   
    foreach (vars, string var) {
        //is array
        if (has_suffix(var, ARRAY_SUFFIX)) {
            string varName = replace(var, ARRAY_SUFFIX, "");
            if (search(decodedQuery, varName + "[") >= 0) {
                query[varName] = server[VAR_PREFIX + var] / "#";
            }
        }
        else{
            if (search(decodedQuery, var + "=") >= 0) {
                query[var] = server[VAR_PREFIX + var];
            }
        }
    }

    return query;
}


import ".";

constant VAR_PREFIX = "VAR_";

mapping server;
mapping input = ([]);
mapping query = ([]);
mapping cookies = ([]);
// mapping files = ([]);

void create(mapping server)
{
    this_program::server = server;
}

void parseParams()
{
    if (server["VARIABLES"]) {
        array inputVars = server["VARIABLES"] / " ";
        //store all vars in input
        foreach (inputVars;; string varName) {
            int varLength = strlen(varName);
            string value = server[VAR_PREFIX + varName];

            // if varName do not end in '_' is a simple var!!!
            if (!has_suffix(varName, "_")) {
                input[varName] = value;
                continue;
            }

            //array value
            if (varEndsWithParUnder(varName)) {
                varName = varName[..(varLength-3)];
                input[varName] = value / "#";
                continue;
            }

            //if varName ends only with one '_' is a mapping 
            if (varEndWithOnlyUnder(varName)) {
                array partsOfvar = (varName / "_") - ({""});
                varName = partsOfvar[0];
                input[varName] += mapArrayOfvariables(partsOfvar[1..], value);
                continue;
            }

            //mapping value
            if (varEndsWithImparUnder(varName)) {
                array partsOfvar = (varName / "_") - ({""});
                array arrayValue = value / "#";
                varName = partsOfvar[0];
                input[varName] += mapArrayOfvariables(partsOfvar[1..], arrayValue);
                continue;
            }        
        }
    }
        
    //array queryVars = server["QUERY_STRING"] ? / "&";
    
    //parse cookies
    if (server["HTTP_COOKIE"]) {
        array cookieVars = (server["COOKIES"] / " ") - ({""});
        foreach(cookieVars;; string cookieName) {
            cookies[cookieName] = server["COOKIE_" + cookieName];
        }
    }
}

mapping getInputParams()
{
    return this_program::input;
}

mapping getQueryParams()
{
    return this_program::query;
}

mapping getCookieParams()
{
    return this_program::cookies;
}

// mapping getFiles()
// {
//     return this_program::files;
// }

private bool varEndWithOnlyUnder(string varName)
{
    int len = strlen(varName);
    return varName[(len-1)..] == "_" && varName[(len-2)..(len-2)] != "_";
}

private bool varEndsWithParUnder(string varName) 
{
    int len = strlen(varName);
    return ( varName[(len-2)..] == "__" && varName[(len-3)..(len-3)] != "_" );
}

private bool varEndsWithImparUnder(string varName) 
{
    int len = strlen(varName);
    return varName[(len-3)..] == "___" && varName[(len-4)..(len-4)] != "_";
}

private mapping mapArrayOfvariables(array variables, mixed value) 
{
    //stop condition
    if (sizeof(variables) == 1) {
        return ([variables[0]: value]);
    }

    array newvariables = Array.pop(variables);

    return mapArrayOfvariables(newvariables[1], ([newvariables[0]: value]));
}
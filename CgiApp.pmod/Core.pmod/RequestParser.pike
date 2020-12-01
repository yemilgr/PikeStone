import ".";

constant VAR_PREFIX = "VAR_";

mapping server;

void create(mapping server)
{
    this_program::server = server;
}

mapping parseParams()
{
    mapping params = ([]);
    if (zero_type(server["VARIABLES"]))
        return params;

    array vars = server["VARIABLES"] / " ";

    foreach (vars;; string varName) {
        int varLength = strlen(varName);
        string value = server[VAR_PREFIX + varName];

        // if varName do not end in '_' is a simple var right!!!
        if (!has_suffix(varName, "_")) {
            params[varName] = value;
            continue;
        }

        //array value
        if (varEndsWithParUnder(varName)) {
            varName = varName[..(varLength-3)];
            params[varName] = value / "#";
            continue;
        }

        //if varName ends only with one '_' is a mapping 
        if (varEndWithOnlyUnder(varName)) {
            array partsOfvar = (varName / "_") - ({""});
            params[partsOfvar[0]] += mapArrayOfvariables(partsOfvar[1..], value);
            continue;
        }

        //mapping value
        if (varEndsWithImparUnder(varName)) {
            array partsOfvar = (varName / "_") - ({""});
            array arrayValue = value / "#";
            params[partsOfvar[0]] += mapArrayOfvariables(partsOfvar[1..], arrayValue);
            continue;
        }        
    }

    return params;
}

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

mapping mapArrayOfvariables(array variables, mixed value) 
{
    //stop condition
    if (sizeof(variables) == 1) {
        return ([variables[0]: value]);
    }

    array newvariables = Array.pop(variables);

    return mapArrayOfvariables(newvariables[1], ([newvariables[0]: value]));
}
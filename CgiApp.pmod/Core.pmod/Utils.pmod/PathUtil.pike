import ".";

string removeTrailingSlash(string path)
{
    int len = strlen(String.trim_whites(path));

    //obvious reason
    if (len == 1)
        return path;

    // if last char is '/' then removed from path
    if (path[(len-1)..] == "/") 
        return path[..(len-2)];
    
    return path;
}
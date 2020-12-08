// Result Class 

mixed resource;

object create(mixed resource)
{
    this_program::resource = resource;
    return this_object();
}


// Retorna un mapping optimizat, per defecte els noms dels camps son en miniscules!
array(mapping(string:mixed)) get() 
{
    array(mapping(string:mixed)) res = ({});

    if(resource && objectp(resource) && resource->num_rows() > 0){
        array(int|string) fieldnames;
        int|array(string|int|float) row;
        array(mapping(string:mixed)) fields = (array(mapping(string:mixed)))resource->fetch_fields();

        if(!sizeof(fields)){
            return res;
        }

        fieldnames = (array(string))fields->name;
        
        while(row = resource->fetch_row()){
            res += ({ mkmapping(fieldnames, (array)row) });
        }
    }

    return res;
}

mapping(string:string) row() {
    mapping(string:string) res = ([]);

    if(resource && objectp(resource) && resource->num_rows() > 0){
        int i;
        int sz_f = 0;
        array(string|int) fieldnames;
        int|array(string|int|float) row;
        array(mapping) fields = (array(mapping))resource->fetch_fields();

        sz_f = sizeof(fields);

        if(!sz_f){
            return res;
        }

        fieldnames = map((array(string))fields->name, lower_case);

        // limit 1, no necesito un while
        if(row = resource->fetch_row()){
            for(i = 0; i < sz_f; i++){
                res |= ([ (string)fieldnames[i]: (string)row[i] ]);
            }
        }
    }

    return res;
}
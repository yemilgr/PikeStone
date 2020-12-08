import ".";

object db;

string connection = "default";

string table = "";

string pk = "id";


object create()
{
    this_program::db = DB.Connection(connection);
    return this_object();
}

object queryBuilder(string|void alias)
{
    return DB.QueryBuilder(db, table, alias);
}

mixed query(string query, mapping|void params)
{
    return DB.Result(db->big_query(query, params))->get();
}

mixed find(mixed id)
{
    return findBy(pk, id);
}

mixed findBy(string column, mixed value)
{
    string query = "";

    if (arrayp(value)) {
        value = db->quote(
            map(value, lambda(mixed val) { return (string)val; }) * ","
        );
        query = sprintf("SELECT * FROM %s WHERE %s IN (%s)", table, column, value);
    } else {
        value = db->quote((string)value);
        query = sprintf("SELECT * FROM %s WHERE %s = %s", table, column, value);
    }
    
    return DB.Result(db->big_query(query))->get();
}

mixed findAll()
{
    string query = sprintf("SELECT * FROM %s", table);

    return DB.Result(db->big_query(query))->get();
}

mixed insert(mapping data)
{
    array quotedValues = map(values(data), lambda(mixed val) { 
        return stringp(val) ? sprintf("'%s'", db->quote(val)) : db->quote((string)val);
    });

    string columns = indices(data) * ",";
    string values = quotedValues * ",";

    string query = sprintf("INSERT INTO %s (%s) VALUES (%s)", table, columns, values);
    
    return db->query(query);
}

mixed update(mixed id, mapping data)
{
    return updateWhere(pk, id, data);
}

mixed updateWhere(string column, mixed value, mapping data)
{
    string sets = "";
    foreach(data; string column; mixed val) {
        val = stringp(val) ? sprintf("'%s'", db->quote(val)) : db->quote((string)val);
        sets += sprintf("%s = %s,", column, val);
    }
    sets = sets[0..sizeof(sets)-2]; //strip last ',' char
    
    string query = "";
    if (arrayp(value)) {
        value = db->quote(
            map(value, lambda(mixed val) { return (string)val; }) * ","
        );
        query = sprintf("UPDATE %s SET %s WHERE %s IN (%s)", table, sets, column, value);
    } else {
        value = db->quote((string)value);
        query = sprintf("UPDATE %s SET %s WHERE %s = %s", table, sets, column, value);
    }

    return db->query(query);
}

// if exist update, otherwise insert
void save(mapping data)
{

}

mixed delete(mixed id)
{
    return deleteWhere(pk, id);
}

mixed deleteWhere(string column, mixed value)
{
    string query = "";
    if (arrayp(value)) {
        value = db->quote(
            map(value, lambda(mixed val) { return (string)val; }) * ","
        );
        query = sprintf("DELETE FROM %s WHERE %s IN (%s)", table, column, value);
    } else {
        value = db->quote((string)value);
        query = sprintf("DELETE FROM %s WHERE %s = %s", table, column, value);
    }

    return db->query(query);
}

// mapping findCustomFieldsBy(string query, string column, mixed value)
// {
//     query = sprintf( query, table, column );

//     return db.get_result(
//         db->big_query(query, ([":value" : value]))
//     );
// }

// mapping findCustomFieldsAndParams(string customFields, string alias, string column, mixed value){
//     string query = sprintf("select %s from %s as %s where %s = :value limit 1", customFields, table, alias, column);
    
//     return db.get_result(
//         db->big_query(query, ([":value" : value]))
//     );
// }

// mapping findCustomFieldsAndManyParams(string customFields, string alias, mapping values){
//     string query = sprintf("select %s from %s as %s where %s limit 1", customFields, table, alias, where(values) );
    
//     return db.get_result(
//         db->big_query(query)
//     );
// }

// int insert(mapping data)
// {
//     string columns = indices( data ) * ",";
//     string values = values( data ) * ",";
//     string insert = sprintf( "insert into %s (%s) values (%s)", table, columns, values );
//     db->query( insert );
// }


// string where( mapping values ){
//     string whereQuery = "";
//     array columns = indices( values );
//     for( int i = 0; i < sizeof( columns ); i++){
//         whereQuery += columns[i] + "='" + values[columns[i]] + "'";
//         if ( ! i + 1 == sizeof( values ) ) whereQuery += " and ";
//     }
//     return whereQuery;
// }
// QueryBuilder Class
import ".";

object db;

string table;

string alias;

string queryAction = "SELECT";

string querySelect = "*";

array whereConditions = ({});

// // array groupWhere = ({});
// // array orGroupWhere = ({});

int queryLimit = 100;

int queryOffset = 0;


object create(object db, string table, string|void alias)
{
    this_program::db = db;
    this_program::table = table;
    this_program::alias = !zero_type(alias) ? alias : table[0..0];

    return this_object();
}

mixed first()
{
    string query = this_program::getCompiledQuery();

    return Result(db->big_query(query))->row();
}

// mixed get(int|void limit, int|void offset)
// {
//     if (!zero_type(limit)) {
//         queryLimit = limit;
//     }

//     if (!zero_type(offset)) {
//         queryOffset = offset;
//     }

//     string query = this_program::getCompiledQuery();

//     return Result(db->big_query(query))->get();
// }

// mixed getWhere(mapping where, int|void limit, int|void offset)
// {
//     foreach (where; string column, mixed value) {
//         this_program::where(column, value);
//     }

//     return this_program::get(limit, offset);
// }

// int count()
// {}

// void exec()
// {}

// object select(string columns) 
// {
//     this_program::select = columns;
//     return this_object();
// }

// object selectMax(string column) 
// {
//     this_program::select = sprintf("MAX(%s) as %s", column, column);
//     return this_object();
// }

// object where(string column, mixed value)
// {
//     value = quoteParam(value);

//     string OP = sizeof(whereConditions == 0) ? "WHERE" : "AND";
    
//     whereConditions += ({sprintf("%s %s = %s ", OP, column, value)});
    
//     return this_object();
// }

// object orWhere(string column, mixed value)
// {
//     value = quoteParam(value);

//     string OP = sizeof(whereConditions == 0) ? "WHERE" : "OR";
    
//     whereConditions += ({sprintf("%s %s = %s ", OP, column, value)});
    
//     return this_object();
// }

// object limit(int limit) 
// {
//     this_program::limit
// }


// compile query
private string getCompiledQuery()
{
    string query = "";

    // select 
    query += sprintf("SELECT %s ", querySelect);

    // source
    query += sprintf("FROM %s ", table);

    // where conditions 
    if (whereConditions) {
        query += whereConditions * "";
    }
   
    // limits 
    if (queryLimit) {
        query += sprintf("LIMIT %s OFFSET %s ", (string)queryLimit, (string)queryOffset);
    }
    
    return query;
}

private string quoteParam(mixed param)
{
    return stringp(param) ? sprintf("'%s'", db->quote(param)) : db->quote((string)param);
}
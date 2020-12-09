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

array orderByConditions = ({});

array queryJoins = ({});

int queryLimit;

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
    string query = this_program::getQuery();

    return Result(db->big_query(query))->row();
}

mixed get(int|void limit, int|void offset)
{
    if (!zero_type(limit)) {
        this_program::queryLimit = limit;
    }

    if (!zero_type(offset)) {
        this_program::queryOffset = offset;
    }

    string query = this_program::getQuery();

    return Result(db->big_query(query))->get();
}

mixed getWhere(mapping conditions, int|void limit, int|void offset)
{
    foreach (conditions; string column; mixed value) {
        this_program::where(column, value);
    }

    return this_program::get(limit, offset);
}

int count()
{
    this_program::querySelect = "COUNT(*) as count";

    string query = this_program::getQuery();

    return (int) Result(db->big_query(query))->row()["count"];
}


object select(string columns) 
{
    this_program::querySelect = columns;
    return this_object();
}

object selectMax(string column) 
{
    this_program::querySelect = sprintf("MAX(%s) as %s", column, column);
    return this_object();
}

object selectMin(string column) 
{
    this_program::querySelect = sprintf("MIN(%s) as %s", column, column);
    return this_object();
}

object where(string column, mixed value)
{
    value = quoteParam(value);

    string operator = sizeof(whereConditions) == 0 ? "WHERE" : "AND";
    
    whereConditions += ({sprintf("%s %s.%s = %s ", operator, alias, column, value)});
    
    return this_object();
}

object orWhere(string column, mixed value)
{
    value = quoteParam(value);

    string operator = sizeof(whereConditions) == 0 ? "WHERE" : "OR";
    
    whereConditions += ({sprintf("%s %s.%s = %s ", operator, alias, column, value)});
    
    return this_object();
}

object whereIn(string column, array values)
{
    string operator = sizeof(whereConditions) == 0 ? "WHERE" : "AND";
    
    string quotedValues = map(values, this_program::quoteParam) * ",";

    whereConditions += ({sprintf("%s %s.%s IN (%s) ", operator, alias, column, quotedValues)});
    
    return this_object();
}

object orWhereIn(string column, array values)
{
    string operator = sizeof(whereConditions) == 0 ? "WHERE" : "OR";
    
    string quotedValues = map(values, this_program::quoteParam) * ",";

    whereConditions += ({sprintf("%s %s.%s IN (%s) ", operator, alias, column, quotedValues)});
    
    return this_object();
}

object orderBy(string column, string|void direction)
{
    direction = !zero_type(direction) ? direction : "ASC";

    this_program::orderByConditions += ({ sprintf("%s.%s %s ", alias, column, direction) });

    return this_object();
}

object innerJoin(string joinTable, string joinCondition) 
{
    queryJoins += ({sprintf("INNER JOIN %s ON %s ", joinTable, joinCondition)});

    return this_object();
}

object leftJoin(string joinTable, string joinCondition) 
{
    queryJoins += ({ sprintf("LEFT JOIN %s ON %s ", joinTable, joinCondition) });

    return this_object();
}

object rightJoin(string joinTable, string joinCondition) 
{
    queryJoins += ({ sprintf("RIGHT JOIN %s ON %s ", joinTable, joinCondition) });

    return this_object();
}

object outerJoin(string joinTable, string joinCondition) 
{
    queryJoins += ({ sprintf("OUTER JOIN %s ON %s ", joinTable, joinCondition) });

    return this_object();
}

object limit(int limit) 
{
    this_program::queryLimit = limit;
    
    return this_object();
}

object offset(int offset) 
{
    this_program::queryOffset = offset;
    
    return this_object();
}

// compile query
string getQuery()
{
    string query = "";

    // select 
    query += sprintf("SELECT %s ", querySelect);

    // source
    query += sprintf("FROM %s %s ", table, alias);

    // joins
    if (sizeof(queryJoins)) {
        query += queryJoins * "";
    }

    // where conditions 
    if (sizeof(whereConditions)) {
        query += whereConditions * "";
    }

    // order
    if (sizeof(orderByConditions)) {
        query += "ORDER BY " + (orderByConditions * ",");
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
// ----------------------
// Database configuration
// ----------------------
constant CONNECTION = ([
    "default": ([
        "host": "mysql://127.0.0.1:3306",
        "database": "localhost",
        "user": "user",
        "password": "secret",
        "options": ([
            "reconnect":1,
            // "mysql_charset_name"  : "utf8",
            // "unicode_decode_mode" : 1 
        ])
    ])
]);

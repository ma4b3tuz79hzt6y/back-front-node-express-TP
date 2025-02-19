const mysql = require('mysql2');

const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '12345678',
    database: 'mon_app',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

module.exports = db;


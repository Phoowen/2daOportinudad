const sqlite3 = require('sqlite3').verbose();
const path = require('path');

// Ruta de la base de datos
const dbPath = path.join(__dirname, '../../database.sqlite');

// Conectar a SQLite
const db = new sqlite3.Database(dbPath, (err) => {
    if (err) {
        console.error('❌ Error al conectar a SQLite:', err.message);
    } else {
        console.log('✅ Conectado a la base de datos SQLite');
        createTables();
    }
});

// Crear tablas si no existen
function createTables() {
    // Tabla de usuarios
    db.run(`
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `, (err) => {
        if (err) {
            console.error('❌ Error creando tabla users:', err.message);
        } else {
            console.log('✅ Tabla "users" lista');
        }
    });

    // Tabla de tareas
    db.run(`
        CREATE TABLE IF NOT EXISTS tasks (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            titulo TEXT NOT NULL,
            descripcion TEXT,
            prioridad TEXT CHECK(prioridad IN ('alta', 'media', 'baja')) DEFAULT 'media',
            estado TEXT CHECK(estado IN ('pendiente', 'en_progreso', 'hecha')) DEFAULT 'pendiente',
            fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
            fecha_limite DATETIME,
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )
    `, (err) => {
        if (err) {
            console.error('❌ Error creando tabla tasks:', err.message);
        } else {
            console.log('✅ Tabla "tasks" lista');
        }
    });
}

module.exports = db;
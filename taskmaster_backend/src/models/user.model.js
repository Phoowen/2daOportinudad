const db = require('../config/database');
const bcrypt = require('bcryptjs');

class User {
    // Crear un nuevo usuario
    static create(userData, callback) {
        const { username, email, password } = userData;
        
        // Primero verificar si el usuario ya existe
        const checkSql = `SELECT id FROM users WHERE email = ? OR username = ?`;
        db.get(checkSql, [email, username], (err, row) => {
            if (err) return callback(err);
            
            if (row) {
                return callback(new Error('El email o username ya está registrado'));
            }
            
            // Encriptar la contraseña
            bcrypt.hash(password, 10, (hashErr, passwordHash) => {
                if (hashErr) return callback(hashErr);
                
                const insertSql = `
                    INSERT INTO users (username, email, password_hash) 
                    VALUES (?, ?, ?)
                `;
                
                db.run(insertSql, [username, email, passwordHash], function(insertErr) {
                    if (insertErr) return callback(insertErr);
                    
                    callback(null, {
                        id: this.lastID,
                        username,
                        email,
                        created_at: new Date().toISOString()
                    });
                });
            });
        });
    }

    // Buscar usuario por email
    static findByEmail(email, callback) {
        const sql = `SELECT * FROM users WHERE email = ?`;
        db.get(sql, [email], callback);
    }

    // Buscar usuario por ID (sin password)
    static findById(id, callback) {
        const sql = `
            SELECT id, username, email, created_at 
            FROM users 
            WHERE id = ?
        `;
        db.get(sql, [id], callback);
    }

    // Verificar contraseña
    static verifyPassword(password, hashedPassword, callback) {
        bcrypt.compare(password, hashedPassword, callback);
    }
}

module.exports = User;
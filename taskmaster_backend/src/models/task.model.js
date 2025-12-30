const db = require('../config/database');

class Task {
    // Crear nueva tarea
    static create(taskData, callback) {
        const { user_id, titulo, descripcion, prioridad, estado, fecha_limite } = taskData;
        
        const sql = `
            INSERT INTO tasks (user_id, titulo, descripcion, prioridad, estado, fecha_limite)
            VALUES (?, ?, ?, ?, ?, ?)
        `;
        
        const params = [
            user_id, 
            titulo, 
            descripcion || '',
            prioridad || 'media',
            estado || 'pendiente',
            fecha_limite || null
        ];
        
        db.run(sql, params, function(err) {
            if (err) return callback(err);
            
            // Obtener la tarea recién creada
            this.lastID ? this.get(this.lastID, user_id, callback) : callback(null, null);
        }.bind(this));
    }

    // Obtener tarea por ID
    static get(id, userId, callback) {
        const sql = `SELECT * FROM tasks WHERE id = ? AND user_id = ?`;
        db.get(sql, [id, userId], callback);
    }

    // Obtener todas las tareas de un usuario
    static getAll(userId, filters = {}, callback) {
        let sql = `SELECT * FROM tasks WHERE user_id = ?`;
        const params = [userId];
        
        // Aplicar filtros
        if (filters.estado) {
            sql += ` AND estado = ?`;
            params.push(filters.estado);
        }
        
        if (filters.prioridad) {
            sql += ` AND prioridad = ?`;
            params.push(filters.prioridad);
        }
        
        // Ordenar
        sql += ` ORDER BY 
            CASE prioridad 
                WHEN 'alta' THEN 1
                WHEN 'media' THEN 2
                WHEN 'baja' THEN 3
            END,
            fecha_limite ASC`;
        
        db.all(sql, params, callback);
    }

    // Actualizar tarea
    static update(id, userId, taskData, callback) {
        const { titulo, descripcion, prioridad, estado, fecha_limite } = taskData;
        
        const sql = `
            UPDATE tasks 
            SET titulo = ?, descripcion = ?, prioridad = ?, estado = ?, fecha_limite = ?
            WHERE id = ? AND user_id = ?
        `;
        
        const params = [
            titulo,
            descripcion || '',
            prioridad || 'media',
            estado || 'pendiente',
            fecha_limite || null,
            id,
            userId
        ];
        
        db.run(sql, params, function(err) {
            if (err) return callback(err);
            
            if (this.changes === 0) {
                return callback(new Error('Tarea no encontrada o no autorizada'));
            }
            
            // Obtener la tarea actualizada
            this.get(id, userId, callback);
        }.bind(this));
    }

    // Eliminar tarea
    static delete(id, userId, callback) {
        const sql = `DELETE FROM tasks WHERE id = ? AND user_id = ?`;
        
        db.run(sql, [id, userId], function(err) {
            if (err) return callback(err);
            
            callback(null, { deleted: this.changes > 0 });
        });
    }
}

module.exports = Task;
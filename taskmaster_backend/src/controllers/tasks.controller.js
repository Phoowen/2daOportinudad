const Task = require('../models/task.model');

const tasksController = {
    getAllTasks: async (req, res) => {
        try {
            const userId = req.user.id;
            const filters = {};
            
            if (req.query.estado) filters.estado = req.query.estado;
            if (req.query.prioridad) filters.prioridad = req.query.prioridad;
            
            Task.getAll(userId, filters, (err, tasks) => {
                if (err) {
                    return res.status(500).json({
                        success: false,
                        error: 'Error al obtener tareas'
                    });
                }
                
                res.json({
                    success: true,
                    data: { tasks: tasks || [] },
                    count: tasks ? tasks.length : 0
                });
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                error: 'Error interno del servidor'
            });
        }
    },

    getTaskById: async (req, res) => {
        try {
            const { id } = req.params;
            const userId = req.user.id;
            
            Task.get(id, userId, (err, task) => {
                if (err) {
                    return res.status(500).json({
                        success: false,
                        error: 'Error al obtener la tarea'
                    });
                }
                
                if (!task) {
                    return res.status(404).json({
                        success: false,
                        error: 'Tarea no encontrada'
                    });
                }
                
                res.json({
                    success: true,
                    data: { task }
                });
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                error: 'Error interno del servidor'
            });
        }
    },

    createTask: async (req, res) => {
        try {
            const userId = req.user.id;
            const taskData = {
                user_id: userId,
                ...req.body
            };
            
            Task.create(taskData, (err, task) => {
                if (err) {
                    return res.status(400).json({
                        success: false,
                        error: err.message
                    });
                }
                
                res.status(201).json({
                    success: true,
                    message: 'Tarea creada exitosamente',
                    data: { task }
                });
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                error: 'Error interno del servidor'
            });
        }
    },

    updateTask: async (req, res) => {
        try {
            const { id } = req.params;
            const userId = req.user.id;
            
            Task.update(id, userId, req.body, (err, task) => {
                if (err) {
                    return res.status(400).json({
                        success: false,
                        error: err.message
                    });
                }
                
                res.json({
                    success: true,
                    message: 'Tarea actualizada exitosamente',
                    data: { task }
                });
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                error: 'Error interno del servidor'
            });
        }
    },

    deleteTask: async (req, res) => {
        try {
            const { id } = req.params;
            const userId = req.user.id;
            
            Task.delete(id, userId, (err, result) => {
                if (err) {
                    return res.status(500).json({
                        success: false,
                        error: 'Error al eliminar la tarea'
                    });
                }
                
                if (!result.deleted) {
                    return res.status(404).json({
                        success: false,
                        error: 'Tarea no encontrada'
                    });
                }
                
                res.json({
                    success: true,
                    message: 'Tarea eliminada exitosamente'
                });
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                error: 'Error interno del servidor'
            });
        }
    }
};

module.exports = tasksController;
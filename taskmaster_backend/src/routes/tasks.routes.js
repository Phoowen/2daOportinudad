const express = require('express');
const router = express.Router();
const tasksController = require('../controllers/tasks.controller');
const { validateTask } = require('../middleware/validation.middleware');
const authMiddleware = require('../middleware/auth.middleware');

// Todas las rutas requieren autenticación
router.use(authMiddleware);

// @route   GET /api/tasks
// @desc    Obtener todas las tareas del usuario
// @access  Private
router.get('/', tasksController.getAllTasks);

// @route   GET /api/tasks/:id
// @desc    Obtener una tarea específica
// @access  Private
router.get('/:id', tasksController.getTaskById);

// @route   POST /api/tasks
// @desc    Crear nueva tarea
// @access  Private
router.post('/', validateTask, tasksController.createTask);

// @route   PUT /api/tasks/:id
// @desc    Actualizar tarea
// @access  Private
router.put('/:id', validateTask, tasksController.updateTask);

// @route   DELETE /api/tasks/:id
// @desc    Eliminar tarea
// @access  Private
router.delete('/:id', tasksController.deleteTask);

module.exports = router;
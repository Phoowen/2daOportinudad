require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

// Importar rutas
const authRoutes = require('./routes/auth.routes');
const taskRoutes = require('./routes/tasks.routes');

// Importar configuración de base de datos
require('./config/database');

// Crear aplicación Express
const app = express();  // ⭐⭐ ESTA LÍNEA DEBE IR ANTES DE app.use() ⭐⭐

// Middleware CORS - PERMITE TODO
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Accept');
    res.header('Access-Control-Allow-Credentials', 'true');
    
    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }
    
    next();
});

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
app.use((req, res, next) => {
    console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
    next();
});

// Rutas
app.use('/api/auth', authRoutes);
app.use('/api/tasks', taskRoutes);

// Ruta de prueba
app.get('/', (req, res) => {
    res.json({
        message: '🚀 API de TaskMaster funcionando',
        version: '1.0.0',
        endpoints: {
            auth: {
                register: 'POST /api/auth/register',
                login: 'POST /api/auth/login',
                profile: 'GET /api/auth/profile (requiere token)'
            },
            tasks: {
                getAll: 'GET /api/tasks (requiere token)',
                getOne: 'GET /api/tasks/:id (requiere token)',
                create: 'POST /api/tasks (requiere token)',
                update: 'PUT /api/tasks/:id (requiere token)',
                delete: 'DELETE /api/tasks/:id (requiere token)'
            }
        },
        documentation: 'Ver README.md para más detalles'
    });
});

// Ruta de salud
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// Manejo de errores 404
app.use('*', (req, res) => {
    res.status(404).json({
        success: false,
        error: `Ruta no encontrada: ${req.originalUrl}`
    });
});

// Middleware de manejo de errores
app.use((err, req, res, next) => {
    console.error('❌ Error:', err.stack);
    
    res.status(err.status || 500).json({
        success: false,
        error: process.env.NODE_ENV === 'development' 
            ? err.message 
            : 'Error interno del servidor',
        ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
    });
});

// Puerto
const PORT = process.env.PORT || 3000;

// Iniciar servidor
app.listen(PORT, () => {
    console.log('='.repeat(50));
    console.log(`🚀 Servidor TaskMaster iniciado`);
    console.log(`📍 Puerto: ${PORT}`);
    console.log(`🌍 Entorno: ${process.env.NODE_ENV}`);
    console.log(`📚 API Docs: http://localhost:${PORT}`);
    console.log(`💾 Base de datos: database.sqlite`);
    console.log('='.repeat(50));
    console.log('\n📋 Endpoints disponibles:');
    console.log(`   POST   http://localhost:${PORT}/api/auth/register`);
    console.log(`   POST   http://localhost:${PORT}/api/auth/login`);
    console.log(`   GET    http://localhost:${PORT}/api/tasks`);
    console.log('='.repeat(50));
});

module.exports = app;
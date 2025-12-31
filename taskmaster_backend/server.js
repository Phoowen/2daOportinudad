const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');

// Cargar variables de entorno
dotenv.config();

// Crear aplicación Express
const app = express();  // ¡ESTO FALTABA!

// ========== MIDDLEWARE ==========
// CORS para desarrollo
app.use(cors({
  origin: '*',  // Permitir todos en desarrollo
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept']
}));

// Parsear JSON
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ========== RUTAS BÁSICAS ==========
// Health check
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    message: 'Backend funcionando correctamente',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});

// Ruta de prueba
app.get('/api/test', (req, res) => {
  res.json({ message: 'API funcionando correctamente' });
});

// ========== RUTAS DE AUTENTICACIÓN ==========
// Registro de usuario
app.post('/api/auth/register', (req, res) => {
  try {
    const { username, email, password } = req.body;
    
    // Validación básica
    if (!username || !email || !password) {
      return res.status(400).json({ 
        error: 'Todos los campos son requeridos' 
      });
    }
    
    // Simular creación de usuario (en producción usarías base de datos)
    const mockUser = {
      id: 1,
      username,
      email,
      createdAt: new Date()
    };
    
    res.status(201).json({
      success: true,
      message: 'Usuario registrado exitosamente',
      data: { user: mockUser }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Login de usuario
app.post('/api/auth/login', (req, res) => {
  try {
    const { email, password } = req.body;
    
    // Validación básica
    if (!email || !password) {
      return res.status(400).json({ 
        error: 'Email y contraseña son requeridos' 
      });
    }
    
    // Credenciales de prueba (en producción verificarías en DB)
    const testUsers = [
      { email: 'admin@taskmaster.com', password: 'Admin123!', id: 1, username: 'admin' },
      { email: 'usuario@taskmaster.com', password: 'Usuario123!', id: 2, username: 'usuario' },
      { email: 'demo@taskmaster.com', password: 'Demo123!', id: 3, username: 'demo' },
      { email: 'ozarate025@gmail.com', password: 'ZowenZ2525', id: 4, username: 'ozarate' }
    ];
    
    const user = testUsers.find(u => u.email === email && u.password === password);
    
    if (!user) {
      return res.status(401).json({ 
        error: 'Credenciales inválidas' 
      });
    }
    
    // Simular token JWT (en producción usarías jsonwebtoken)
    const mockToken = `mock_jwt_token_${Date.now()}_${user.id}`;
    
    res.json({
      success: true,
      message: 'Login exitoso',
      data: {
        user: {
          id: user.id,
          username: user.username,
          email: user.email
        },
        token: mockToken,
        expiresIn: '7d'
      }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ========== RUTAS DE TAREAS (CRUD) ==========
// Mock de tareas
let tasks = [
  { id: 1, user_id: 1, titulo: 'Revisar informe', descripcion: 'Revisar informe mensual', prioridad: 'alta', estado: 'pendiente', fecha_creacion: new Date(), fecha_limite: new Date(Date.now() + 7*24*60*60*1000) },
  { id: 2, user_id: 1, titulo: 'Preparar presentación', descripcion: 'Diapositivas para reunión', prioridad: 'media', estado: 'en_progreso', fecha_creacion: new Date(), fecha_limite: new Date(Date.now() + 3*24*60*60*1000) },
  { id: 3, user_id: 1, titulo: 'Actualizar documentación', descripcion: 'Actualizar README', prioridad: 'baja', estado: 'hecha', fecha_creacion: new Date(), fecha_limite: new Date(Date.now() - 24*60*60*1000) }
];

// Middleware de autenticación simple
const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token no proporcionado' });
  }
  
  // Simular verificación de token (en producción verificarías JWT)
  const token = authHeader.split(' ')[1];
  if (!token.includes('mock_jwt_token')) {
    return res.status(401).json({ error: 'Token inválido' });
  }
  
  // Extraer user_id del token (simulado)
  const userIdMatch = token.match(/mock_jwt_token_\d+_(\d+)/);
  if (userIdMatch) {
    req.userId = parseInt(userIdMatch[1]);
  } else {
    req.userId = 1; // Default para pruebas
  }
  
  next();
};

// Obtener todas las tareas del usuario
app.get('/api/tasks', authenticate, (req, res) => {
  const userTasks = tasks.filter(task => task.user_id === req.userId);
  res.json({
    success: true,
    data: { tasks: userTasks }
  });
});

// Crear nueva tarea
app.post('/api/tasks', authenticate, (req, res) => {
  try {
    const { titulo, descripcion, prioridad, estado, fecha_limite } = req.body;
    
    if (!titulo) {
      return res.status(400).json({ error: 'El título es requerido' });
    }
    
    const newTask = {
      id: tasks.length + 1,
      user_id: req.userId,
      titulo,
      descripcion: descripcion || '',
      prioridad: prioridad || 'media',
      estado: estado || 'pendiente',
      fecha_creacion: new Date(),
      fecha_limite: fecha_limite ? new Date(fecha_limite) : null
    };
    
    tasks.push(newTask);
    
    res.status(201).json({
      success: true,
      message: 'Tarea creada exitosamente',
      data: { task: newTask }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Obtener tarea por ID
app.get('/api/tasks/:id', authenticate, (req, res) => {
  const taskId = parseInt(req.params.id);
  const task = tasks.find(t => t.id === taskId && t.user_id === req.userId);
  
  if (!task) {
    return res.status(404).json({ error: 'Tarea no encontrada' });
  }
  
  res.json({
    success: true,
    data: { task }
  });
});

// Actualizar tarea
app.put('/api/tasks/:id', authenticate, (req, res) => {
  try {
    const taskId = parseInt(req.params.id);
    const taskIndex = tasks.findIndex(t => t.id === taskId && t.user_id === req.userId);
    
    if (taskIndex === -1) {
      return res.status(404).json({ error: 'Tarea no encontrada' });
    }
    
    const { titulo, descripcion, prioridad, estado, fecha_limite } = req.body;
    
    tasks[taskIndex] = {
      ...tasks[taskIndex],
      titulo: titulo || tasks[taskIndex].titulo,
      descripcion: descripcion !== undefined ? descripcion : tasks[taskIndex].descripcion,
      prioridad: prioridad || tasks[taskIndex].prioridad,
      estado: estado || tasks[taskIndex].estado,
      fecha_limite: fecha_limite ? new Date(fecha_limite) : tasks[taskIndex].fecha_limite
    };
    
    res.json({
      success: true,
      message: 'Tarea actualizada exitosamente',
      data: { task: tasks[taskIndex] }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Eliminar tarea
app.delete('/api/tasks/:id', authenticate, (req, res) => {
  const taskId = parseInt(req.params.id);
  const initialLength = tasks.length;
  
  tasks = tasks.filter(t => !(t.id === taskId && t.user_id === req.userId));
  
  if (tasks.length === initialLength) {
    return res.status(404).json({ error: 'Tarea no encontrada' });
  }
  
  res.json({
    success: true,
    message: 'Tarea eliminada exitosamente'
  });
});

// ========== CONFIGURACIÓN DEL SERVIDOR ==========
const PORT = process.env.PORT || 3000;
const HOST = process.env.HOST || '0.0.0.0';  // IMPORTANTE: escuchar en todas las interfaces

app.listen(PORT, HOST, () => {
  console.log('='.repeat(60));
  console.log('🚀 BACKEND TASKMASTER INICIADO CORRECTAMENTE');
  console.log('='.repeat(60));
  console.log(`📡 Servidor corriendo en:`);
  console.log(`   🔗 Local: http://localhost:${PORT}`);
  console.log(`   🔗 Red: http://${require('os').networkInterfaces().Ethernet?.[0]?.address || 'IP_NO_ENCONTRADA'}:${PORT}`);
  console.log('');
  console.log('📋 Endpoints disponibles:');
  console.log(`   ✅ Health check: GET http://localhost:${PORT}/api/health`);
  console.log(`   👤 Registro: POST http://localhost:${PORT}/api/auth/register`);
  console.log(`   🔑 Login: POST http://localhost:${PORT}/api/auth/login`);
  console.log(`   📝 Tareas: GET http://localhost:${PORT}/api/tasks`);
  console.log('='.repeat(60));
  
  // Mostrar credenciales de prueba
  console.log('\n👥 CREDENCIALES DE PRUEBA:');
  console.log('   📧 Email: admin@taskmaster.com');
  console.log('   🔐 Password: Admin123!');
  console.log('');
  console.log('   📧 Email: ozarate025@gmail.com');
  console.log('   🔐 Password: ZowenZ2525');
  console.log('='.repeat(60));
});
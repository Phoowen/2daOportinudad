# nOWte.app Backend API
API REST para aplicación de gestión de tareas con autenticación JWT.

Las tecnologías utilizadas para el proyecto fueron:
Runtime: Node.js
Framework: Express.js
Base de datos: SQLite
Autenticación: JWT (JSON Web Token)

## Requisitos ##
- Node.js v16+
- Postman
- SQLite
- Github
- Flutter

✨ Características Principales
Funcionalidad	Descripción	Estado
📝 Gestión de Tareas	CRUD completo con prioridades y estados	✅ Completo
👤 Autenticación	Registro y login con JWT seguro	✅ Completo
🌤️ Clima en Tiempo Real	Pronóstico por ciudad con OpenWeather API	✅ Completo
📰 Noticias por Categoría	Noticias actualizadas con NewsAPI	✅ Completo
📊 Estadísticas	Dashboard con métricas de productividad	✅ Completo
🎨 Temas	Modo claro/oscuro personalizable	✅ Completo
📱 Multiplataforma	iOS, Android y Web responsive	✅ Completo

Instalación 

bash
# 1. Clonar repositorio
git clone https://github.com/tu-usuario/taskmaster-app.git
cd taskmaster-app

# 2. Configurar Backend
cd backend
cp .env.example .env
# Editar .env con tus credenciales
npm install
npm start

# 3. Configurar Frontend
cd ../frontend
cp .env.example .env
# Agregar tus API Keys
flutter pub get
flutter run

Backend (Node.js API)
bash
# Instalar dependencias
cd backend
npm install

# Configurar variables de entorno
# Editar el archivo .env:
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=tu_password
DB_NAME=taskmaster_db
JWT_SECRET=tu_super_secreto_jwt_123456
NODE_ENV=development

# Configurar base de datos
mysql -u root -p < database/schema.sql

# Iniciar servidor
npm start          # Producción
npm run dev        # Desarrollo con hot reload

# La API estará disponible en:
# http://localhost:3000/api


Frontend (Flutter App)
bash
# Instalar dependencias
cd frontend
flutter pub get

# Configurar variables de entorno
# Editar el archivo .env:
API_BASE_URL=http://10.0.2.2:3000/api
OPENWEATHER_API_KEY=8e887b0cebde1f87d3ae74b79a2c5f8a 
NEWS_API_KEY=0a5b71fd2a104f198418301d10c1c8c1

# Obtener API Keys gratuitas:
# - OpenWeather: https://openweathermap.org/api
# - NewsAPI: https://newsapi.org/register

# Ejecutar la aplicación
flutter run        # Dispositivo conectado
flutter run -d web # Navegador web

# Build para producción
flutter build apk --release
flutter build ios --release
flutter build web --release

📖 API Documentation
Endpoints Principales
Método	Endpoint	Descripción	Autenticación
POST	/api/auth/register	Registrar nuevo usuario	❌
POST	/api/auth/login	Iniciar sesión	❌
GET	/api/auth/profile	Obtener perfil	✅
GET	/api/tasks	Listar tareas	✅
POST	/api/tasks	Crear tarea	✅
PUT	/api/tasks/:id	Actualizar tarea	✅
DELETE	/api/tasks/:id	Eliminar tarea	✅
GET	/api/weather/:city	Obtener clima	✅
GET	/api/news	Obtener noticias	✅
Ejemplos de Requests
<details> <summary>Ver ejemplos de uso</summary>
Registro de Usuario
http
POST /api/auth/register
Content-Type: application/json

{
  "username": "juanperez",
  "email": "juan@email.com",
  "password": "SecurePass123"
}
Login
http
POST /api/auth/login
Content-Type: application/json

{
  "email": "juan@email.com",
  "password": "SecurePass123"
}

# Respuesta exitosa
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "juanperez",
    "email": "juan@email.com"
  }
}
Crear Tarea
http
POST /api/tasks
Authorization: Bearer {token}
Content-Type: application/json

{
  "titulo": "Revisar informe mensual",
  "descripcion": "Revisar y aprobar informe financiero del mes",
  "prioridad": "media",
  "estado": "pendiente",
  "fecha_limite": "2024-12-31T23:59:59Z"
}
</details>
👥 Credenciales de Prueba
yaml
# Usuario de prueba (se crea automáticamente en primera ejecución)
Email: ejemplocorreo@gmail.com
Password: 123456
// (En caso de no funcionar ese usuario, crear uno nuevo o usar el siguiente) //
Email: ozarate025@gmail.com
Password: ZowenZ2525

📊 Base de Datos
<details> <summary>Ver esquema completo</summary>
sql
-- Tabla de Usuarios
CREATE TABLE users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) UNIQUE NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tabla de Tareas
CREATE TABLE tasks (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  titulo VARCHAR(200) NOT NULL,
  descripcion TEXT,
  prioridad ENUM('alta', 'media', 'baja') DEFAULT 'media',
  estado ENUM('pendiente', 'en_progreso', 'hecha') DEFAULT 'pendiente',
  fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  fecha_limite DATETIME,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  INDEX idx_user_status (user_id, estado),
  INDEX idx_user_priority (user_id, prioridad)
);

-- Tabla de Sesiones (opcional para refresh tokens)
CREATE TABLE user_sessions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
</details>
🔍 Troubleshooting
Problema	Solución
Error de conexión a DB	Verificar credenciales en .env y que MySQL esté corriendo
API Keys no funcionan	Verificar límites de uso y regenerar keys en los portales
App no carga datos	Verificar conexión a internet y CORS en backend
Build falla en iOS	Ejecutar pod install en carpeta ios/
Performance lento	Usar flutter build --release y habilitar caching

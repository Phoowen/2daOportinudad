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
<details> <summary>Ver configuración completa</summary>
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
# Documentación Swagger:
# http://localhost:3000/api-docs
</details>

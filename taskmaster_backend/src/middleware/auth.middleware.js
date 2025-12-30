const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
    try {
        // Obtener token del header
        const authHeader = req.headers.authorization;
        
        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                error: 'Acceso denegado. Token no proporcionado.'
            });
        }
        
        const token = authHeader.split(' ')[1];
        
        // Verificar token
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        
        // Añadir usuario al request
        req.user = {
            id: decoded.id,
            email: decoded.email,
            username: decoded.username
        };
        
        next();
    } catch (error) {
        return res.status(401).json({
            success: false,
            error: 'Token inválido o expirado.'
        });
    }
};

module.exports = authMiddleware;
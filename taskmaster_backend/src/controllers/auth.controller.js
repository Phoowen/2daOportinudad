const jwt = require('jsonwebtoken');
const User = require('../models/user.model');

const authController = {
    register: async (req, res) => {
        try {
            const { username, email, password } = req.body;
            
            // Crear usuario
            User.create({ username, email, password }, (err, user) => {
                if (err) {
                    return res.status(400).json({
                        success: false,
                        error: err.message
                    });
                }
                
                // Generar token JWT
                const token = jwt.sign(
                    {
                        id: user.id,
                        username: user.username,
                        email: user.email
                    },
                    process.env.JWT_SECRET,
                    { expiresIn: '7d' }
                );
                
                res.status(201).json({
                    success: true,
                    message: 'Usuario registrado exitosamente',
                    data: {
                        token,
                        user: {
                            id: user.id,
                            username: user.username,
                            email: user.email,
                            created_at: user.created_at
                        }
                    }
                });
            });
            
        } catch (error) {
            res.status(500).json({
                success: false,
                error: 'Error interno del servidor'
            });
        }
    },

    login: async (req, res) => {
        try {
            const { email, password } = req.body;
            
            // Buscar usuario
            User.findByEmail(email, async (err, user) => {
                if (err || !user) {
                    return res.status(401).json({
                        success: false,
                        error: 'Credenciales inválidas'
                    });
                }
                
                // Verificar contraseña
                User.verifyPassword(password, user.password_hash, (err, isValid) => {
                    if (err || !isValid) {
                        return res.status(401).json({
                            success: false,
                            error: 'Credenciales inválidas'
                        });
                    }
                    
                    // Generar token
                    const token = jwt.sign(
                        {
                            id: user.id,
                            username: user.username,
                            email: user.email
                        },
                        process.env.JWT_SECRET,
                        { expiresIn: '7d' }
                    );
                    
                    res.json({
                        success: true,
                        message: 'Login exitoso',
                        data: {
                            token,
                            user: {
                                id: user.id,
                                username: user.username,
                                email: user.email,
                                created_at: user.created_at
                            }
                        }
                    });
                });
            });
            
        } catch (error) {
            res.status(500).json({
                success: false,
                error: 'Error interno del servidor'
            });
        }
    },

    getProfile: async (req, res) => {
        try {
            User.findById(req.user.id, (err, user) => {
                if (err || !user) {
                    return res.status(404).json({
                        success: false,
                        error: 'Usuario no encontrado'
                    });
                }
                
                res.json({
                    success: true,
                    data: { user }
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

module.exports = authController;
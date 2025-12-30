const validateRegister = (req, res, next) => {
    const { username, email, password } = req.body;
    const errors = [];

    // Validar username
    if (!username || username.trim().length < 3) {
        errors.push('El username debe tener al menos 3 caracteres');
    }

    // Validar email
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!email || !emailRegex.test(email)) {
        errors.push('Email inválido');
    }

    // Validar password
    if (!password || password.length < 6) {
        errors.push('La contraseña debe tener al menos 6 caracteres');
    }

    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            errors
        });
    }

    next();
};

const validateLogin = (req, res, next) => {
    const { email, password } = req.body;
    const errors = [];

    if (!email) errors.push('Email es requerido');
    if (!password) errors.push('Contraseña es requerida');

    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            errors
        });
    }

    next();
};

const validateTask = (req, res, next) => {
    const { titulo } = req.body;
    const errors = [];

    if (!titulo || titulo.trim().length === 0) {
        errors.push('El título es requerido');
    }

    if (req.body.prioridad && !['alta', 'media', 'baja'].includes(req.body.prioridad)) {
        errors.push('Prioridad debe ser: alta, media o baja');
    }

    if (req.body.estado && !['pendiente', 'en_progreso', 'hecha'].includes(req.body.estado)) {
        errors.push('Estado debe ser: pendiente, en_progreso o hecha');
    }

    if (errors.length > 0) {
        return res.status(400).json({
            success: false,
            errors
        });
    }

    next();
};

module.exports = {
    validateRegister,
    validateLogin,
    validateTask
};
const jwt = require('jsonwebtoken');

// Verifikasi Token Login
exports.verifyToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ');

    if (!token) {
        return res.status(401).json({ status: 'error', message: 'Akses ditolak. Silakan login terlebih dahulu.' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(403).json({ status: 'error', message: 'Token tidak valid atau sudah kedaluwarsa.' });
        }
        req.user = decoded;
        next();
    });
};

// Otorisasi Khusus Role Admin
exports.isAdmin = (req, res, next) => {
    if (req.user.role !== 'admin') {
        return res.status(403).json({ status: 'error', message: 'Akses ditolak. Fitur ini hanya untuk Admin.' });
    }
    next();
};

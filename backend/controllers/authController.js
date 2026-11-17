const db = require('../config/db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Register Akun Baru (Sesuai Form Register Flutter)
exports.register = async (req, res) => {
    const { nama_lengkap, email, password, role } = req.body;

    if (!nama_lengkap || !email || !password) {
        return res.status(400).json({ status: 'error', message: 'Nama lengkap, email, dan password wajib diisi.' });
    }

    try {
        const [existing] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(400).json({ status: 'error', message: 'Email sudah terdaftar.' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const userRole = role && role.toLowerCase() === 'admin' ? 'admin' : 'kasir';

        await db.query(
            'INSERT INTO users (nama_lengkap, email, password, role) VALUES (?, ?, ?, ?)',
            [nama_lengkap, email, hashedPassword, userRole]
        );

        res.status(201).json({ status: 'success', message: 'Registrasi berhasil! Silakan login.' });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

// Login User
exports.login = async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ status: 'error', message: 'Email dan password wajib diisi.' });
    }

    try {
        const [users] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({ status: 'error', message: 'Email atau password salah.' });
        }

        const user = users;
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
            return res.status(401).json({ status: 'error', message: 'Email atau password salah.' });
        }

        const token = jwt.sign(
            { id_user: user.id_user, role: user.role, nama_lengkap: user.nama_lengkap },
            process.env.JWT_SECRET,
            { expiresIn: '1d' }
        );

        res.status(200).json({
            status: 'success',
            message: 'Login berhasil',
            data: {
                token,
                user: {
                    id_user: user.id_user,
                    nama_lengkap: user.nama_lengkap,
                    email: user.email,
                    role: user.role
                }
            }
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

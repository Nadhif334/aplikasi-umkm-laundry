const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');
const pelangganRoutes = require('./routes/pelangganRoutes');
const pesananRoutes = require('./routes/pesananRoutes');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Menyajikan folder uploads secara statis agar foto bisa diakses Flutter
app.use('/uploads', express.static('uploads'));

// Routing API
app.use('/api/auth', authRoutes);
app.use('/api/pelanggan', pelangganRoutes);
app.use('/api/pesanan', pesananRoutes);

// Penanganan Error Global (termasuk validasi upload Multer)
app.use((err, req, res, next) => {
    res.status(400).json({
        status: 'error',
        message: err.message || 'Terjadi kesalahan pada server'
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server UMKM Laundry berjalan di http://localhost:${PORT}`);
});

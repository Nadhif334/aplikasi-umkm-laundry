const db = require('../config/db');

// Ambil semua daftar pesanan (JOIN tabel pelanggan)
exports.getAllPesanan = async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT p.id_pesanan, p.id_pelanggan, pl.nama_pelanggan, pl.no_hp,
                   p.jenis_layanan, p.berat_kg, p.total_harga, p.status_cucian, 
                   p.foto_cucian, p.tanggal_masuk
            FROM pesanan p
            JOIN pelanggan pl ON p.id_pelanggan = pl.id_pelanggan
            ORDER BY p.id_pesanan DESC
        `);
        res.status(200).json({ status: 'success', data: rows });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

// Ambil detail 1 pesanan
exports.getPesananById = async (req, res) => {
    const { id } = req.params;
    try {
        const [rows] = await db.query(`
            SELECT p.*, pl.nama_pelanggan, pl.no_hp 
            FROM pesanan p 
            JOIN pelanggan pl ON p.id_pelanggan = pl.id_pelanggan 
            WHERE p.id_pesanan = ?
        `, [id]);

        if (rows.length === 0) {
            return res.status(404).json({ status: 'error', message: 'Pesanan tidak ditemukan.' });
        }
        res.status(200).json({ status: 'success', data: rows });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

// Tambah pesanan baru + Upload Foto Cucian
exports.createPesanan = async (req, res) => {
    const { id_pelanggan, jenis_layanan, berat_kg, total_harga, status_cucian } = req.body;
    const id_user = req.user.id_user;
    const foto_cucian = req.file ? req.file.filename : null;

    if (!id_pelanggan || !jenis_layanan || !berat_kg || !total_harga) {
        return res.status(400).json({ status: 'error', message: 'Semua field pesanan wajib diisi.' });
    }

    try {
        const [result] = await db.query(
            `INSERT INTO pesanan (id_pelanggan, id_user, jenis_layanan, berat_kg, total_harga, status_cucian, foto_cucian) 
             VALUES (?, ?, ?, ?, ?, ?, ?)`,
            [id_pelanggan, id_user, jenis_layanan, berat_kg, total_harga, status_cucian || 'Proses', foto_cucian]
        );
        res.status(201).json({
            status: 'success',
            message: 'Pesanan berhasil dibuat',
            data: { id_pesanan: result.insertId, foto_cucian }
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

// Update Pesanan (Sesuai Form Edit Pesanan Flutter)
exports.updatePesanan = async (req, res) => {
    const { id } = req.params;
    const { jenis_layanan, berat_kg, total_harga, status_cucian } = req.body;
    const foto_cucian = req.file ? req.file.filename : null;

    try {
        if (foto_cucian) {
            await db.query(
                `UPDATE pesanan SET jenis_layanan = ?, berat_kg = ?, total_harga = ?, status_cucian = ?, foto_cucian = ? 
                 WHERE id_pesanan = ?`,
                [jenis_layanan, berat_kg, total_harga, status_cucian, foto_cucian, id]
            );
        } else {
            await db.query(
                `UPDATE pesanan SET jenis_layanan = ?, berat_kg = ?, total_harga = ?, status_cucian = ? 
                 WHERE id_pesanan = ?`,
                [jenis_layanan, berat_kg, total_harga, status_cucian, id]
            );
        }
        res.status(200).json({ status: 'success', message: 'Pesanan berhasil diperbarui' });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

// Hapus Pesanan (Khusus Role Admin)
exports.deletePesanan = async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM pesanan WHERE id_pesanan = ?', [id]);
        res.status(200).json({ status: 'success', message: 'Pesanan berhasil dihapus' });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

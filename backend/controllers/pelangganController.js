const db = require('../config/db');

exports.getAllPelanggan = async (req, res) => {
    try {
        const [rows] = await db.query('SELECT * FROM pelanggan ORDER BY id_pelanggan DESC');
        res.status(200).json({ status: 'success', data: rows });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

exports.createPelanggan = async (req, res) => {
    const { nama_pelanggan, no_hp, alamat } = req.body;
    if (!nama_pelanggan || !no_hp) {
        return res.status(400).json({ status: 'error', message: 'Nama pelanggan dan nomor HP wajib diisi.' });
    }

    try {
        const [result] = await db.query(
            'INSERT INTO pelanggan (nama_pelanggan, no_hp, alamat) VALUES (?, ?, ?)',
            [nama_pelanggan, no_hp, alamat || '-']
        );
        res.status(201).json({
            status: 'success',
            message: 'Data pelanggan berhasil ditambahkan',
            data: { id_pelanggan: result.insertId, nama_pelanggan, no_hp, alamat }
        });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

exports.updatePelanggan = async (req, res) => {
    const { id } = req.params;
    const { nama_pelanggan, no_hp, alamat } = req.body;
    try {
        await db.query(
            'UPDATE pelanggan SET nama_pelanggan = ?, no_hp = ?, alamat = ? WHERE id_pelanggan = ?',
            [nama_pelanggan, no_hp, alamat, id]
        );
        res.status(200).json({ status: 'success', message: 'Data pelanggan berhasil diperbarui' });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

exports.deletePelanggan = async (req, res) => {
    const { id } = req.params;
    try {
        await db.query('DELETE FROM pelanggan WHERE id_pelanggan = ?', [id]);
        res.status(200).json({ status: 'success', message: 'Data pelanggan berhasil dihapus' });
    } catch (error) {
        res.status(500).json({ status: 'error', message: error.message });
    }
};

const express = require('express');
const router = express.Router();
const pelangganController = require('../controllers/pelangganController');
const { verifyToken, isAdmin } = require('../middlewares/authMiddleware');

router.get('/', verifyToken, pelangganController.getAllPelanggan);
router.post('/', verifyToken, pelangganController.createPelanggan);
router.put('/:id', verifyToken, pelangganController.updatePelanggan);
router.delete('/:id', verifyToken, isAdmin, pelangganController.deletePelanggan); // Hanya Admin

module.exports = router;

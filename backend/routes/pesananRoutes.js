const express = require('express');
const router = express.Router();
const pesananController = require('../controllers/pesananController');
const { verifyToken, isAdmin } = require('../middlewares/authMiddleware');
const upload = require('../middlewares/uploadMiddleware');

router.get('/', verifyToken, pesananController.getAllPesanan);
router.get('/:id', verifyToken, pesananController.getPesananById);
router.post('/', verifyToken, upload.single('foto_cucian'), pesananController.createPesanan);
router.put('/:id', verifyToken, upload.single('foto_cucian'), pesananController.updatePesanan);
router.delete('/:id', verifyToken, isAdmin, pesananController.deletePesanan); // Hanya Admin

module.exports = router;

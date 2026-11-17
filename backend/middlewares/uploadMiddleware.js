const multer = require('multer');
const path = require('path');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads/');
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + '-' + Math.round(Math.random() * 1E9) + path.extname(file.originalname));
    }
});

const fileFilter = (req, file, cb) => {
    const allowedTypes = /jpeg|jpg|png/;
    const isExtValid = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const isMimeValid = allowedTypes.test(file.mimetype);

    if (isExtValid && isMimeValid) {
        cb(null, true);
    } else {
        cb(new Error('Format file tidak didukung. Gunakan JPG, JPEG, atau PNG!'));
    }
};

const upload = multer({
    storage: storage,
    limits: { fileSize: 2 * 1024 * 1024 }, // Maksimal 2 MB
    fileFilter: fileFilter
});

module.exports = upload;

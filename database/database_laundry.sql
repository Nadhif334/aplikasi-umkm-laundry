CREATE DATABASE IF NOT EXISTS db_umkm_laundry;
USE db_umkm_laundry;

-- 1. Tabel Users (Autentikasi & Otorisasi)
CREATE TABLE users (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    nama_lengkap VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'kasir') NOT NULL DEFAULT 'kasir',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Tabel Pelanggan (Data Utama 1 - Relasi Foreign Key)
CREATE TABLE pelanggan (
    id_pelanggan INT AUTO_INCREMENT PRIMARY KEY,
    nama_pelanggan VARCHAR(100) NOT NULL,
    no_hp VARCHAR(20) NOT NULL,
    alamat TEXT
);

-- 3. Tabel Pesanan (Data Utama 2 - Sesuai UI Flutter + Kolom Foto)
CREATE TABLE pesanan (
    id_pesanan INT AUTO_INCREMENT PRIMARY KEY,
    id_pelanggan INT NOT NULL,
    id_user INT NOT NULL,
    jenis_layanan VARCHAR(100) NOT NULL,
    berat_kg DECIMAL(5,2) NOT NULL,
    total_harga INT NOT NULL,
    status_cucian ENUM('Proses', 'Selesai', 'Diambil') NOT NULL DEFAULT 'Proses',
    foto_cucian VARCHAR(255) NULL,
    tanggal_masuk DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pelanggan) REFERENCES pelanggan(id_pelanggan) ON DELETE CASCADE,
    FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE RESTRICT
);

-- Data Awal (DML) & Akun Pengujian (Password: 123456)
INSERT INTO users (nama_lengkap, email, password, role) VALUES
('Admin Laundry', 'admin@laundry.com', '$2a$10$8K1p/a0dL1LXMIgoEDFrwOfMQ161iL2F0h6V6.zO8vJ5w2Q4K5W6e', 'admin'),
('Kasir Laundry', 'kasir@laundry.com', '$2a$10$8K1p/a0dL1LXMIgoEDFrwOfMQ161iL2F0h6V6.zO8vJ5w2Q4K5W6e', 'kasir');

INSERT INTO pelanggan (nama_pelanggan, no_hp, alamat) VALUES
('Budi Santoso', '081234567890', 'Jl. Merdeka No. 10, Depok'),
('Siti Aminah', '089876543210', 'Jl. Margonda Raya No. 45, Depok');

INSERT INTO pesanan (id_pelanggan, id_user, jenis_layanan, berat_kg, total_harga, status_cucian, foto_cucian) VALUES
(1, 2, 'Cuci Komplit Express', 3.50, 25000, 'Proses', NULL);

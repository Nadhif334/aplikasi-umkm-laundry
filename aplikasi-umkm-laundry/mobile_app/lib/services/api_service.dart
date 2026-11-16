import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pesanan_model.dart';

class ApiService {
  static const String imageUrl = '';

  // Data awal simulasi (Pelanggan)
  static Future<List<dynamic>> getPelanggan() async {
    return [
      {'id': 1, 'nama_pelanggan': 'Budi Santoso', 'no_hp': '081234567890'},
      {'id': 2, 'nama_pelanggan': 'Siti Aminah', 'no_hp': '089876543210'},
      {'id': 3, 'nama_pelanggan': 'Andi Wijaya', 'no_hp': '085611223344'},
    ];
  }

  // REGISTER LOKAL
  static Future<Map<String, dynamic>> register(
      String nama, String email, String password, String role) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> usersJson = prefs.getStringList('local_users') ?? [];

    // Cek email duplikat
    for (var u in usersJson) {
      final map = jsonDecode(u);
      if (map['email'] == email) {
        return {'status': false, 'message': 'Email sudah terdaftar'};
      }
    }

    usersJson.add(jsonEncode({
      'nama': nama,
      'email': email,
      'password': password,
      'role': role,
    }));
    await prefs.setStringList('local_users', usersJson);

    return {'status': true, 'message': 'Registrasi berhasil'};
  }

  // LOGIN LOKAL (Sudah disediakan akun bawaan admin & kasir)
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Akun bawaan siap pakai
    if (email == 'admin@umkm.com' && password == '123456') {
      await prefs.setString('token', 'token_admin_lokal');
      await prefs.setString('role', 'admin');
      await prefs.setString('nama', 'Admin Laundry');
      return {'status': true, 'message': 'Login Berhasil'};
    }
    if (email == 'kasir@umkm.com' && password == '123456') {
      await prefs.setString('token', 'token_kasir_lokal');
      await prefs.setString('role', 'kasir');
      await prefs.setString('nama', 'Kasir Laundry');
      return {'status': true, 'message': 'Login Berhasil'};
    }

    // Cek akun yang didaftarkan lewat halaman Register
    List<String> usersJson = prefs.getStringList('local_users') ?? [];
    for (var u in usersJson) {
      final map = jsonDecode(u);
      if (map['email'] == email && map['password'] == password) {
        await prefs.setString('token', 'token_${map['email']}');
        await prefs.setString('role', map['role']);
        await prefs.setString('nama', map['nama']);
        return {'status': true, 'message': 'Login Berhasil'};
      }
    }

    return {'status': false, 'message': 'Email atau password salah!'};
  }

  // GET PESANAN LOKAL
  static Future<List<PesananModel>> getPesanan() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> dataJson = prefs.getStringList('local_pesanan') ?? [];

    // Jika kosong, isi 1 data contoh awal
    if (dataJson.isEmpty) {
      final contoh = {
        'id': 1,
        'pelanggan_id': 1,
        'nama_pelanggan': 'Budi Santoso',
        'no_hp': '081234567890',
        'jenis_layanan': 'Cuci Komplit Express',
        'berat_kg': 3.5,
        'total_harga': 25000,
        'status': 'Proses',
        'foto_cucian': null,
      };
      dataJson.add(jsonEncode(contoh));
      await prefs.setStringList('local_pesanan', dataJson);
    }

    return dataJson
        .map((e) => PesananModel.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList();
  }

  // CREATE PESANAN LOKAL
  static Future<bool> tambahPesanan(
      Map<String, String> fields, File? imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> dataJson = prefs.getStringList('local_pesanan') ?? [];

    final pelangganList = await getPelanggan();
    final pelId = int.parse(fields['pelanggan_id'] ?? '1');
    final pel = pelangganList.firstWhere(
      (element) => element['id'] == pelId,
      orElse: () => {'nama_pelanggan': 'Pelanggan Umum', 'no_hp': '-'},
    );

    final baru = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'pelanggan_id': pelId,
      'nama_pelanggan': pel['nama_pelanggan'],
      'no_hp': pel['no_hp'],
      'jenis_layanan': fields['jenis_layanan'],
      'berat_kg': double.tryParse(fields['berat_kg'] ?? '0') ?? 0.0,
      'total_harga': int.tryParse(fields['total_harga'] ?? '0') ?? 0,
      'status': 'Proses',
      'foto_cucian': kIsWeb ? null : imageFile?.path,
    };

    dataJson.add(jsonEncode(baru));
    await prefs.setStringList('local_pesanan', dataJson);
    return true;
  }

  // UPDATE PESANAN LOKAL
  static Future<bool> updatePesanan(int id, Map<String, dynamic> body) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> dataJson = prefs.getStringList('local_pesanan') ?? [];

    for (int i = 0; i < dataJson.length; i++) {
      Map<String, dynamic> item = jsonDecode(dataJson[i]);
      if (item['id'] == id) {
        item['jenis_layanan'] = body['jenis_layanan'];
        item['berat_kg'] = body['berat_kg'];
        item['total_harga'] = body['total_harga'];
        item['status'] = body['status'];
        dataJson[i] = jsonEncode(item);
        break;
      }
    }

    await prefs.setStringList('local_pesanan', dataJson);
    return true;
  }

  // DELETE PESANAN LOKAL
  static Future<bool> hapusPesanan(int id) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> dataJson = prefs.getStringList('local_pesanan') ?? [];

    dataJson.removeWhere((e) => jsonDecode(e)['id'] == id);
    await prefs.setStringList('local_pesanan', dataJson);
    return true;
  }
}

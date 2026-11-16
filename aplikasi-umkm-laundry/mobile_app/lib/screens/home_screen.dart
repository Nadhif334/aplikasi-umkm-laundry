import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pesanan_model.dart';
import '../services/api_service.dart';
import 'form_pesanan_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PesananModel> _pesananList = [];
  String _role = 'kasir';
  String _namaUser = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _loading = true);
    final prefs = await SharedPreferences.getInstance();
    final data = await ApiService.getPesanan();
    setState(() {
      _role = prefs.getString('role') ?? 'kasir';
      _namaUser = prefs.getString('nama') ?? 'User';
      _pesananList = data;
      _loading = false;
    });
  }

  void _showDetailDialog(PesananModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detail Pesanan #${item.id}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.fotoCucian != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    '${ApiService.imageUrl}${item.fotoCucian}',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Text('Gagal memuat gambar'),
                  ),
                ),
              SizedBox(height: 12),
              Text('Pelanggan: ${item.namaPelanggan}'),
              Text('No HP: ${item.noHp}'),
              Text('Layanan: ${item.jenisLayanan}'),
              Text('Berat: ${item.beratKg} Kg'),
              Text('Total Harga: Rp ${item.totalHarga}'),
              Text('Status: ${item.status}'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Tutup')),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus data pesanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool sukses = await ApiService.hapusPesanan(id);
              if (sukses) {
                _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal menghapus data'), backgroundColor: Colors.red),
                );
              }
            },
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('UMKM Laundry', style: TextStyle(fontSize: 18)),
            Text('Halo, $_namaUser (${_role.toUpperCase()})', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          )
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _pesananList.isEmpty
              ? Center(child: Text('Belum ada data pesanan'))
              : RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    itemCount: _pesananList.length,
                    itemBuilder: (context, index) {
                      final item = _pesananList[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: ListTile(
                          onTap: () => _showDetailDialog(item),
                          leading: item.fotoCucian != null
                              ? Image.network(
                                  '${ApiService.imageUrl}${item.fotoCucian}',
                                  width: 55,
                                  height: 55,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.broken_image),
                                )
                              : Icon(Icons.local_laundry_service, size: 40, color: Colors.blue),
                          title: Text('${item.namaPelanggan} - ${item.jenisLayanan}'),
                          subtitle: Text('${item.beratKg} kg | Rp ${item.totalHarga}\nStatus: ${item.status}'),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tombol Edit (Bisa diakses Admin & Kasir)
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FormPesananScreen(pesananEdit: item),
                                    ),
                                  );
                                  _loadData();
                                },
                              ),
                              // Pembatasan Role: Tombol Hapus HANYA untuk Admin
                              if (_role == 'admin')
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _confirmDelete(item.id),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FormPesananScreen()),
          );
          _loadData();
        },
      ),
    );
  }
}

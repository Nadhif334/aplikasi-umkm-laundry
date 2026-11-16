import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/pesanan_model.dart';
import '../services/api_service.dart';

class FormPesananScreen extends StatefulWidget {
  final PesananModel? pesananEdit;
  FormPesananScreen({this.pesananEdit});

  @override
  _FormPesananScreenState createState() => _FormPesananScreenState();
}

class _FormPesananScreenState extends State<FormPesananScreen> {
  final _formKey = GlobalKey<FormState>();
  final _layananCtrl = TextEditingController();
  final _beratCtrl = TextEditingController();
  final _hargaCtrl = TextEditingController();

  List<dynamic> _pelangganList = [];
  String? _selectedPelangganId;
  String _selectedStatus = 'Proses';
  File? _image;
  bool _loading = false;

  bool get isEdit => widget.pesananEdit != null;

  @override
  void initState() {
    super.initState();
    _fetchPelanggan();
    if (isEdit) {
      _layananCtrl.text = widget.pesananEdit!.jenisLayanan;
      _beratCtrl.text = widget.pesananEdit!.beratKg.toString();
      _hargaCtrl.text = widget.pesananEdit!.totalHarga.toString();
      _selectedPelangganId = widget.pesananEdit!.pelangganId.toString();
      _selectedStatus = widget.pesananEdit!.status;
    }
  }

  void _fetchPelanggan() async {
    final data = await ApiService.getPelanggan();
    setState(() {
      _pelangganList = data;
      if (!isEdit && data.isNotEmpty) {
        _selectedPelangganId = data[0]['id'].toString();
      }
    });
  }

  Future _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    bool sukses = false;

    if (isEdit) {
      sukses = await ApiService.updatePesanan(widget.pesananEdit!.id, {
        'jenis_layanan': _layananCtrl.text,
        'berat_kg': double.parse(_beratCtrl.text),
        'total_harga': int.parse(_hargaCtrl.text),
        'status': _selectedStatus,
      });
    } else {
      sukses = await ApiService.tambahPesanan({
        'pelanggan_id': _selectedPelangganId ?? '1',
        'jenis_layanan': _layananCtrl.text,
        'berat_kg': _beratCtrl.text,
        'total_harga': _hargaCtrl.text,
      }, _image);
    }

    setState(() => _loading = false);

    if (sukses) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Data berhasil diperbarui!' : 'Pesanan berhasil ditambahkan!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan data'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Pesanan' : 'Tambah Pesanan')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!isEdit) ...[
                DropdownButtonFormField<String>(
                  value: _selectedPelangganId,
                  decoration: InputDecoration(labelText: 'Pilih Pelanggan', border: OutlineInputBorder()),
                  items: _pelangganList.map<DropdownMenuItem<String>>((pel) {
                    return DropdownMenuItem<String>(
                      value: pel['id'].toString(),
                      child: Text(pel['nama_pelanggan']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedPelangganId = val),
                  validator: (val) => val == null ? 'Pelanggan wajib dipilih' : null,
                ),
                SizedBox(height: 12),
              ],
              TextFormField(
                controller: _layananCtrl,
                decoration: InputDecoration(labelText: 'Jenis Layanan (Misal: Cuci Setrika)', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Jenis layanan wajib diisi' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _beratCtrl,
                decoration: InputDecoration(labelText: 'Berat (Kg)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Berat wajib diisi' : null,
              ),
              SizedBox(height: 12),
              TextFormField(
                controller: _hargaCtrl,
                decoration: InputDecoration(labelText: 'Total Harga (Rp)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Total harga wajib diisi' : null,
              ),
              SizedBox(height: 12),
              if (isEdit) ...[
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(labelText: 'Status Cucian', border: OutlineInputBorder()),
                  items: ['Proses', 'Selesai', 'Diambil']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
                SizedBox(height: 12),
              ],
              if (!isEdit) ...[
                _image != null
                    ? Image.file(_image!, height: 150)
                    : Container(
                        height: 100,
                        color: Colors.grey[200],
                        child: Center(child: Text('Belum ada foto cucian dipilih')),
                      ),
                SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.photo_library),
                  label: Text('Pilih Foto Cucian'),
                ),
              ],
              SizedBox(height: 20),
              _loading
                  ? Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _simpan,
                        child: Text(isEdit ? 'Update Pesanan' : 'Simpan Pesanan'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

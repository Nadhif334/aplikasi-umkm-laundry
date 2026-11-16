class PesananModel {
  final int id;
  final int pelangganId;
  final String namaPelanggan;
  final String noHp;
  final String jenisLayanan;
  final double beratKg;
  final int totalHarga;
  final String status;
  final String? fotoCucian;

  PesananModel({
    required this.id,
    required this.pelangganId,
    required this.namaPelanggan,
    required this.noHp,
    required this.jenisLayanan,
    required this.beratKg,
    required this.totalHarga,
    required this.status,
    this.fotoCucian,
  });

  factory PesananModel.fromJson(Map<String, dynamic> json) {
    return PesananModel(
      id: json['id'],
      pelangganId: json['pelanggan_id'],
      namaPelanggan: json['nama_pelanggan'] ?? 'Tanpa Nama',
      noHp: json['no_hp'] ?? '-',
      jenisLayanan: json['jenis_layanan'],
      beratKg: double.parse(json['berat_kg'].toString()),
      totalHarga: int.parse(json['total_harga'].toString()),
      status: json['status'] ?? 'Proses',
      fotoCucian: json['foto_cucian'],
    );
  }
}

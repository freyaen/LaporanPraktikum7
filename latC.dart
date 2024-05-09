import 'package:flutter/material.dart'; // Mengimpor package flutter/material.dart
import 'package:http/http.dart'
    as http; // Mengimpor package http untuk melakukan HTTP request.
import 'dart:convert'; // Mengimpor package dart:convert untuk mengonversi data ke format JSON.
import 'package:flutter_bloc/flutter_bloc.dart'; // Mengimpor package flutter_bloc untuk mengelola state menggunakan BLoC pattern.

void main() {
  // Memulai aplikasi Flutter.
  runApp(MaterialApp(
    // Memulai widget MaterialApp untuk membangun aplikasi Flutter.
    title: 'Universities List', // Memberikan judul untuk aplikasi.
    home: BlocProvider(
      // Menyediakan BlocProvider untuk mengelola state aplikasi.
      create: (context) =>
          CountryBloc(), // Membuat instance dari CountryBloc untuk mengelola state negara.
      child:
          UniversitiesList(), // Menjadikan UniversitiesList sebagai child widget dari BlocProvider.
    ),
  ));
}

class CountryBloc extends Cubit<String> {
  // Mendefinisikan kelas CountryBloc yang mengelola state negara.
  CountryBloc()
      : super(
            'Indonesia'); // Constructor untuk menginisialisasi state dengan nilai default 'Indonesia'.

  void updateCountry(String country) =>
      emit(country); // Metode untuk memperbarui state negara dengan nilai baru.
}

class UniversitiesList extends StatelessWidget {
  // Mendefinisikan kelas UniversitiesList sebagai StatelessWidget.
  const UniversitiesList({Key? key})
      : super(key: key); // Constructor untuk UniversitiesList.

  @override
  Widget build(BuildContext context) {
    // Metode build untuk merender tampilan widget.
    final countryBloc = BlocProvider.of<CountryBloc>(
        context); // Mendapatkan instance CountryBloc dari widget tree.

    return Scaffold(
      // Mengembalikan widget Scaffold sebagai tampilan utama aplikasi.
      appBar: AppBar(
        // Widget AppBar untuk menampilkan judul aplikasi.
        title: Text('Universities List'), // Judul AppBar.
      ),
      body: Center(
        // Widget Center untuk mengatur posisi widget ke tengah layar.
        child: Column(
          // Widget Column untuk menampilkan widget secara vertikal.
          children: [
            // List children berisi widget-widget yang akan ditampilkan dalam Column.
            BlocBuilder<CountryBloc, String>(
              // Widget BlocBuilder untuk membangun widget berdasarkan state dari CountryBloc.
              builder: (context, selectedCountry) {
                // Builder untuk membangun widget DropdownButton berdasarkan state negara yang dipilih.
                return DropdownButton<String>(
                  // Widget DropdownButton untuk memilih negara.
                  value:
                      selectedCountry, // Nilai dropdown diatur berdasarkan state negara yang dipilih.
                  onChanged: (String? newValue) {
                    // Callback yang dipanggil saat nilai dropdown berubah.
                    if (newValue != null) {
                      countryBloc.updateCountry(
                          newValue); // Memperbarui state negara saat nilai dropdown berubah.
                    }
                  },
                  items: <String>[
                    // List item untuk dropdown berisi daftar negara.
                    'Indonesia',
                    'Malaysia',
                    'Singapore',
                    'Thailand',
                    'Vietnam',
                    'Philippines',
                    'Myanmar',
                    'Cambodia',
                    'Laos',
                  ].map<DropdownMenuItem<String>>((String value) {
                    // Mengonversi daftar negara menjadi DropdownMenuItem.
                    return DropdownMenuItem<String>(
                      value: value, // Nilai dropdown item.
                      child: Text(
                          value), // Teks yang ditampilkan pada dropdown item.
                    );
                  }).toList(),
                );
              },
            ),
            Expanded(
              // Widget Expanded untuk memperluas widget ke ukuran maksimum yang tersedia.
              child: BlocBuilder<CountryBloc, String>(
                // Widget BlocBuilder untuk membangun widget berdasarkan state dari CountryBloc.
                builder: (context, selectedCountry) {
                  // Builder untuk membangun widget FutureBuilder berdasarkan state negara yang dipilih.
                  return FutureBuilder<List<University>>(
                    // Widget FutureBuilder untuk menampilkan daftar universitas berdasarkan negara yang dipilih.
                    future: fetchUniversities(
                        selectedCountry), // Future yang akan dijalankan untuk mengambil data universitas.
                    builder: (context, snapshot) {
                      // Builder untuk membangun tampilan berdasarkan hasil future.
                      if (snapshot.hasData) {
                        // Jika data sudah tersedia.
                        return ListView.builder(
                          // Widget ListView.builder untuk menampilkan daftar universitas dalam bentuk list.
                          itemCount:
                              snapshot.data!.length, // Jumlah item dalam list.
                          itemBuilder: (context, index) {
                            // Builder untuk membangun item list.
                            return ListTile(
                              // Widget ListTile untuk menampilkan informasi universitas dalam bentuk list item.
                              title: Text(snapshot.data![index]
                                  .name), // Teks judul universitas.
                              subtitle: Text(snapshot.data![index]
                                  .website), // Teks subjudul berisi website universitas.
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        // Jika terjadi error saat mengambil data.
                        return Text(
                            '${snapshot.error}'); // Tampilkan teks dengan informasi error.
                      }
                      return CircularProgressIndicator(); // Tampilkan indikator loading jika data belum tersedia.
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<University>> fetchUniversities(String country) async {
    // Mendefinisikan fungsi fetchUniversities untuk mengambil data universitas dari API.
    final response = await http.get(
        // Melakukan HTTP GET request untuk mengambil data universitas.
        Uri.parse('http://universities.hipolabs.com/search?country=$country'));

    if (response.statusCode == 200) {
      // Jika response dari API berhasil.
      List<dynamic> data = jsonDecode(
          response.body); // Mendekodekan data JSON dari response body.
      List<University> universities = data
          .map((e) => University.fromJson(e))
          .toList(); // Mengonversi data JSON menjadi list objek University.
      return universities; // Mengembalikan list universitas yang telah diperoleh dari API.
    } else {
      // Jika response tidak berhasil.
      throw Exception('Failed to load universities'); // pesan error.
    }
  }
}

class University {
  // Mendefinisikan kelas University untuk merepresentasikan informasi universitas.
  final String name; // Properti untuk nama universitas.
  final String website; // Properti untuk website universitas.

  University({
    required this.name,
    required this.website,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    // Factory method untuk membuat objek University dari data JSON.
    return University(
      name: json['name'], // Mengambil nilai 'name' dari data JSON.
      website: json['web_pages']
          [0], // Mengambil nilai 'web_pages' index 0 dari data JSON.
    );
  }
}

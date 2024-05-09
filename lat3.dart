import 'package:flutter/material.dart'; //Import dart
import 'package:http/http.dart' as http; //import utk melakukan http
import 'dart:convert'; //conver data JSON
import 'package:provider/provider.dart'; // Import Provider

void main() {
  runApp(
    ChangeNotifierProvider(
      //bagian provider untuk mengelolal state yang berubah
      create: (context) =>
          CountryProvider(), // membuat instance dari CountryProvider yang akan digunakan untuk mengelola negara yang dipilih.
      child: const MaterialApp(
        //membuat aplikasi dengan Material Design.
        title: 'Universities List', //judul
        home: UniversitiesList(), //halaman utama
      ),
    ),
  );
}

class CountryProvider extends ChangeNotifier {
  String selectedCountry = 'Indonesia'; // negara default yang dipilih.

  void updateCountry(String country) {
    //fungsi untuk memperbarui negara yang dipilih.
    selectedCountry =
        country; //untuk memperbarui negara yang dipilih dalam CountryProvider.
    notifyListeners(); //memberi tahu widget yang mendengarkan bahwa state telah berubah.
  }
} //class untuk mengelola state negara.

class UniversitiesList extends StatefulWidget {
  //class widget untuk halaman utama aplikasi.
  const UniversitiesList({Key? key})
      : super(key: key); //memberikan kunci unik kepada widget.

  @override
  _UniversitiesListState createState() =>
      _UniversitiesListState(); //menginisialisasi dan membuat instance
}

class _UniversitiesListState extends State<UniversitiesList> {
  //deklarasi kelas untuk state dari widget
  late Future<List<University>>
      futureUniversities; //menyimpan hasil permintaan data universitas di masa depan.

  @override
  void initState() {
    super
        .initState(); // perintah yang memanggil metode initState() dari kelas superclass
    final countryProvider = Provider.of<CountryProvider>(context,
        listen:
            false); //menggunakan Provider package untuk mengambil instance dari CountryProvider
    futureUniversities = fetchUniversities(
        countryProvider.selectedCountry); //negara yang dipilih
  } ////fungsi yang dipanggil saat widget diinisialisasi.

  Future<List<University>> fetchUniversities(String country) async {
    //fungsi asinkron untuk mengambil data universitas berdasarkan negara.
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country')); //permintaan HTTP GET untuk mengambil data universitas dari API.

    if (response.statusCode == 200) {
      List<dynamic> data =
          jsonDecode(response.body); //mengonversi data JSON menjadi list.
      List<University>
          universities = // list dari objek University yang dibuat dari data JSON.
          data
              .map((e) => University.fromJson(e))
              .toList(); // mentransformasi setiap elemen e dalam list data menjadi objek University
      return universities; //mengembalikan list
    } else {
      throw Exception('Failed to load universities'); // jika error
    }
  }

  @override
  Widget build(BuildContext context) {
    //untuk merender tampilan widget.
    final countryProvider = Provider.of<CountryProvider>(
        context); //mengambil instance dari CountryProvider

    return Scaffold(
      // mengatur tata letak aplikasi.
      appBar: AppBar(
        title: Text('Universities List'),
      ),
      body: Center(
        child: Column(
          children: [
            DropdownButton<String>(
              //dropdown button untuk memilih negara.
              value: countryProvider
                  .selectedCountry, //mengatur nilai yang dipilih pada dropdown
              onChanged: (String? newValue) {
                if (newValue != null) {
                  countryProvider.updateCountry(newValue);
                  setState(() {
                    futureUniversities = fetchUniversities(
                        newValue); //memperbarui daftar universitas berdasarkan negara yang baru dipilih.
                  });
                }
              }, //callback yang dipanggil ketika nilai dropdown berubah
              items: <String>[
                //daftar negara ASEAN
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
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(), //mengonversi daftar negara menjadi item dropdown.
            ),
            FutureBuilder<List<University>>(
              future:
                  futureUniversities, //menetapkan hasil permintaan ke future builder.
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        //menampilkan daftar universitas.
                        return ListTile(
                          title: Text(snapshot.data![index].name),
                          subtitle: Text(snapshot.data![index].website),
                        ); // widget untuk menampilkan informasi universitas dalam daftar.
                      },
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ), //builder untuk menangani hasil permintaan asinkron.
          ],
        ),
      ),
    );
  }
}

class University {
  // deklarasi kelas
  final String name;
  final String website;

  University({
    required this.name,
    required this.website,
  }); // constructor untuk kelas University

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      website: json['web_pages'][0],
    );
  } //factory method untuk membuat objek University dari data JSON.
}

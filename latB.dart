import 'package:flutter/material.dart'; //Import Package dart
import 'package:http/http.dart' as http; //import untuk melakukan HTTP request.
import 'dart:convert'; //mengonversi data ke format JSON.
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Cubit

void main() {
  runApp(
    //Memulai aplikasi Flutter.
    MaterialApp(
      //widget
      title: 'Universities List', //judul
      home: BlocProvider(
        //Menyediakan CountryCubit ke dalam widget tree aplikasi.
        create: (context) => CountryCubit(), //Membuat instance
        child:
            UniversitiesList(), //Menjadikan UniversitiesList sebagai child widget dari BlocProvider.
      ),
    ),
  );
}

class CountryCubit extends Cubit<String> {
  // Mendefinisikan kelas CountryCubit yang mengelola state negara.
  CountryCubit()
      : super(
            'Indonesia'); //Constructor yang menginisialisasi state dengan nilai default 'Indonesia'.

  void updateCountry(String country) =>
      emit(country); //Metode untuk memperbarui state negara dengan nilai baru.
}

class UniversitiesList extends StatefulWidget {
  //Mendefinisikan kelas UniversitiesList sebagai StatefulWidget.
  const UniversitiesList({Key? key})
      : super(
            key:
                key); //Constructor untuk UniversitiesList yang menerima parameter

  @override
  _UniversitiesListState createState() =>
      _UniversitiesListState(); //Mengimplementasikan createState
}

class _UniversitiesListState extends State<UniversitiesList> {
  //State dari UniversitiesList.
  late Future<List<University>>
      futureUniversities; //Deklarasi menampung hasil fetch data universitas.

  @override
  void initState() {
    //inisialisasi state saat widget pertama kali dibuat.
    super.initState(); //Memanggil metode initState dari superclass.
    final countryCubit = BlocProvider.of<CountryCubit>(
        context); //Mendapatkan instance CountryCubit dari widget tree
    futureUniversities = fetchUniversities(countryCubit
        .state); //inisialisasi dengan data universitas berdasarkan negara
    countryCubit.stream.listen((country) {
      // mengupdate futureUniversities saat terjadi perubahan.
      setState(() {
        futureUniversities = fetchUniversities(
            country); //Memperbarui tampilan widget saat terjadi perubahan state.
      });
    });
  }

  Future<List<University>> fetchUniversities(String country) async {
    //engambil data universitas dari API berdasarkan negara yang dipilih.
    final response = await http.get(Uri.parse(
        'http://universities.hipolabs.com/search?country=$country')); //Melakukan HTTP GET request ke API

    if (response.statusCode == 200) {
      //Memeriksa jika response dari API berhasil
      List<dynamic> data =
          jsonDecode(response.body); //mengonversi data JSON menjadi list
      List<University> universities = data
          .map((e) => University.fromJson(e))
          .toList(); //Mengonversi data JSON menjadi list objek
      return universities; //Mengembalikan list universitas dari API.
    } else {
      throw Exception('Failed to load universities'); // cek error
    }
  }

  @override
  Widget build(BuildContext context) {
    //merender tampilan widget.
    return Scaffold(
      //Mengembalikan widget Scaffold yang berisi tampilan aplikasi.
      appBar: AppBar(
        //menampilkan judul 'Universities List'.
        title: Text('Universities List'), //judul
      ),
      body: Center(
        child: Column(
          children: [
            BlocBuilder<CountryCubit, String>(
              builder: (context, selectedCountry) {
                //untuk membangun widget DropdownButton berdasarkan state
                return DropdownButton<String>(
                  //DropdownButton untuk memilih negara.
                  value: selectedCountry, //mengatur nilai yang dipilih
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      BlocProvider.of<CountryCubit>(context)
                          .updateCountry(newValue);
                    } //memperbarui daftar universitas berdasarkan negara yang baru dipilih.
                  },
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
                );
              },
            ),
            Expanded(
              child: FutureBuilder<List<University>>(
                future: futureUniversities,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(snapshot.data![index].name),
                          subtitle: Text(snapshot.data![index].website),
                        ); // widget untuk menampilkan informasi universitas dalam daftar
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return CircularProgressIndicator();
                },
              ),
            ), //Menggunakan FutureBuilder untuk menampilkan daftar universitas berdasarkan futureUniversities.
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

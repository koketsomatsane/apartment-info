

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class Vehicle {
  String regNo;
  String make;
  String photo;
  String year;
  String status;

  Vehicle({
    required this.regNo,
    required this.make,
    required this.photo,
    required this.year,
    required this.status,
  });

  @override
  String toString() => '$regNo|$make|$photo|$year|$status';
}

List<Vehicle> vehicles = [];

Future<void> loadVehiclesFromFile() async {
  vehicles.clear();
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      'C:\\Users\\matsa\\Downloads\\224051673_TPGPROJECT\\flutter_application_1\\lib/vehicles.txt',
    );
    if (await file.exists()) {
      final contents = await file.readAsString();
      print('Loaded vehicles from documents directory');
      _parseVehicleLines(contents.split('\n'));
    } else {
      final assetData = await rootBundle.loadString(
        'C:\\Users\\matsa\\Downloads\\224051673_TPGPROJECT\\flutter_application_1\\lib/vehicles.txt',
      );
      await file.writeAsString(assetData); // Copy initial file from lib
      print('Copied initial vehicles.txt from lib to documents directory');
      _parseVehicleLines(assetData.split('\n'));
    }
  } catch (e) {
    print('Error loading vehicles: $e');
  }
}

Future<void> saveToFile() async {
  try {
    final data = vehicles.map((v) => v.toString()).join('\n');
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      'C:\\Users\\matsa\\Downloads\\224051673_TPGPROJECT\\flutter_application_1\\lib/vehicles.txt',
    );
    await file.writeAsString(data);
    print('Saved vehicles to documents directory');
  } catch (e) {
    print(' Error saving vehicles: $e');
  }
}

void _parseVehicleLines(List<String> lines) {
  for (var line in lines) {
    if (line.trim().isEmpty) continue;
    final parts = line.split('|');
    if (parts.length == 5) {
      vehicles.add(
        Vehicle(
          regNo: parts[0],
          make: parts[1],
          photo: parts[2],
          year: parts[3],
          status: parts[4],
        ),
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadVehiclesFromFile(); // Load vehicles from lib/vehicles.txt on startup
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Vehicle Management App', home: HomeScreen());
  }
}

int vehicleIndex = -1;
Vehicle myStaticVehicle() {
  return Vehicle(
    regNo: vehicles[vehicleIndex].regNo,
    make: vehicles[vehicleIndex].make,
    photo: vehicles[vehicleIndex].photo,
    year: vehicles[vehicleIndex].year,
    status: vehicles[vehicleIndex].status,
  );
}

//===========================================================================

//Question: Home Page
int imageIndex = 0;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _checkVehicles();
  }

  Future<void> _checkVehicles() async {
    if (vehicles.isEmpty) {
      await loadVehiclesFromFile();
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // Refresh when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Management App'),
        backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
      ),
      body: vehicles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = vehicles[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(vehicle.photo.toString()),
                    ),
                    title: Text(
                      vehicles[index].regNo,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(vehicles[index].make),
                    trailing: Text(
                      vehicle.status,
                      style: TextStyle(fontSize: 15, color: Colors.blueGrey),
                    ),
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: const Text(
                              "Are you sure you want to remove this vehicle?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("No"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    vehicles.remove(vehicle);
                                  });
                                  try {
                                    await saveToFile();
                                    print(
                                      '📱 Vehicle deleted and saved successfully',
                                    );
                                  } catch (e) {
                                    print('Error saving after delete: $e');
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  );
                                },
                                child: const Text("Yes"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onTap: () {
                      setState(() {
                        vehicleIndex = index;
                        imageIndex = vehicles.length;
                      });
                      print(vehicleIndex);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              VehicleDetailScreen(vehicle: vehicle),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add',
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditScreen(
                vehicle: Vehicle(
                  regNo: '',
                  make: '',
                  photo: '',
                  year: '',
                  status: '',
                ),
              ),
            ),
          ).then((_) => setState(() {})); // Refresh on return
        },
      ),
    );
  }
}
//=============================================================================

class VehicleDetailScreen extends StatefulWidget {
  const VehicleDetailScreen({super.key, required this.vehicle});
  final Vehicle vehicle;

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.make),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    widget.vehicle.photo.toString(),
                    height: 250,
                    width: 100,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Registration Number:",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(widget.vehicle.regNo),
                    Divider(),
                    SizedBox(height: 8),
                    Text(
                      "Make and Model:",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(widget.vehicle.make),
                    Divider(),

                    SizedBox(height: 8),
                    Text(
                      "Year: ${widget.vehicle.year}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Divider(),

                    SizedBox(height: 8),
                    Text(
                      "Status:",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(widget.vehicle.status),
                    Divider(),

                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        print(myStaticVehicle().make);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditScreen()),
                        );
                      },
                      child: Text('Edit'),
                    ),

                    SizedBox(height: 20),
                    TextButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: const Text(
                                "Are you sure you want to remove this vehicle?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("No"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    setState(() {
                                      vehicles.remove(vehicles[vehicleIndex]);
                                    });
                                    try {
                                      await saveToFile();
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => HomeScreen(),
                                        ),
                                      );
                                      print(
                                        ' Vehicle deleted and saved successfully',
                                      );
                                    } catch (e) {
                                      print(' Error saving after delete: $e');
                                    }
                                  },
                                  child: const Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
//==========================================================================

class AddEditScreen extends StatefulWidget {
  const AddEditScreen({super.key, required Vehicle vehicle});

  @override
  State<AddEditScreen> createState() => _AddEditScreenState();
}

var images = [
  "assets/vehicle_photo.jpg",
  "assets/hyundai.jpg,"
      "assets/isuzu.jpg",
  "assets/bmw.png",
  "assets/jetta.jpeg",
];

class _AddEditScreenState extends State<AddEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _regNoController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  final statuses = ['Active', 'In Maintenance', 'Inactive'];
  String _status = 'Active';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text('Adding and Editing the vehicles information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _regNoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Registration number",
                  prefixIcon: Icon(Icons.car_repair_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Registration number is required";
                  }
                  return null; // Return null if valid
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _makeController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: "Make and Model",
                  prefixIcon: Icon(Icons.precision_manufacturing),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Make and Model must be added";
                  }
                  return null; // Return null if valid
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Year",
                  prefixIcon: Icon(Icons.car_repair_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the production year";
                  }
                  if (!RegExp(r'^\d{4}$').hasMatch(value)) {
                    // Updated to accept 4-digit years
                    return "Enter a valid 4-digit year";
                  }
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year + 1) {
                    return "Enter a valid year (1900-present)";
                  }
                  return null; // Return null if valid
                },
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField(
                value: _status,
                items: statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      String regNo = _regNoController.text.toString();
                      vehicles.add(
                        Vehicle(
                          regNo: regNo,
                          make: _makeController.text,
                          photo: images[imageIndex],
                          year: _yearController.text,
                          status: _status,
                        ),
                      );
                    });
                    await saveToFile();
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
//=============================================================================

class EditScreen extends StatefulWidget {
  const EditScreen({super.key});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _makeController = TextEditingController(
    text: vehicles[vehicleIndex].make,
  );
  final TextEditingController _yearController = TextEditingController(
    text: vehicles[vehicleIndex].year,
  );
  final TextEditingController _regNoController = TextEditingController();

  final statuses = ['Active', 'In Maintenance', 'Inactive'];
  String _status = vehicles[vehicleIndex].status;
  @override
  Widget build(BuildContext context) {
    setState(() {
      _regNoController.text = myStaticVehicle().regNo;
    });
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text('Edit Vehicle Information'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                // initialValue: _regNoController,
                controller: _regNoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Registration number",
                  prefixIcon: Icon(Icons.car_repair_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Registration number is required";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "Enter a registration number";
                  }
                  return value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _makeController,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  labelText: "Make and Model",
                  prefixIcon: Icon(Icons.precision_manufacturing),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Make and Model must be added";
                  }

                  return value;
                },
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Year",
                  prefixIcon: Icon(Icons.car_repair_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vehicle year';
                  }
                  final year = int.tryParse(value);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year + 1) {
                    return 'Please enter a valid year';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              DropdownButtonFormField(
                value: _status,
                items: statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val!),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    if (myStaticVehicle().make != _makeController.text) {
                      vehicles[vehicleIndex].make = _makeController.text
                          .toString();
                    }
                    if (myStaticVehicle().status != _status) {
                      vehicles[vehicleIndex].status = _status;
                    }
                    if (myStaticVehicle().regNo != _regNoController.text) {
                      vehicles[vehicleIndex].regNo = _regNoController.text
                          .toString();
                    }
                    if (myStaticVehicle().year != _yearController.text) {
                      vehicles[vehicleIndex].year = _yearController.text
                          .toString();
                    }
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                  try {
                    await saveToFile();
                    print('Vehicle deleted and saved successfully');
                  } catch (e) {
                    print('Error saving after delete: $e');
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text('Save'),
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
//===========================================================================

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

//Question : Properties

class Property {
  final String title;
  final String location;
  final String desciption;
  final String imagePath;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final double size;

  Property(
    this.title,
    this.location,
    this.imagePath,
    this.bathrooms,
    this.bedrooms,
    this.price,
    this.desciption,
    this.size,
  );
}

final List<Property> properties = [
  Property(
    "3-Bedroom Apartment",
    "Cape Town, South Africa",
    "assets/House1.png",
    3,
    2,
    25000000,
    "A modern apartment with stunning views of Table, open-plan kitchen, and secure planning.",
    120,
  ),
  Property(
    "Luxury Villa",
    "Johannesburg, South Africa",
    "assets/House2.png",
    3,
    2,
    65000000,
    "A modern apartment with stunning views of Table, open-plan kitchen, and secure planning.",
    120,
  ),
  Property(
    "Cozy Cottage",
    "Durban, South Africa",
    "assets/House3.jpeg",
    3,
    2,
    25000000,
    "A modern apartment with stunning views of Table, open-plan kitchen, and secure planning.",
    120,
  ),
];

//Question: Home Page
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Properties'),
        backgroundColor: const Color.fromRGBO(33, 150, 243, 1),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: properties.length,
        itemBuilder: (context, index) {
          final property = properties[index];
          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.house_sharp,
                size: 60,
                color: Colors.green,
              ),

              title: Text(
                properties[index].title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(properties[index].location),
              trailing: Text(
                "R ${properties[index].price}",
                style: TextStyle(fontSize: 15, color: Colors.blueGrey),
              ),
              onTap: () {
                //Displays apartments on tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SecondScreen(property: property),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
//===========================================================================

//Question : SecondScreen

class SecondScreen extends StatelessWidget {
  final Property property;
  const SecondScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(property.title), backgroundColor: Colors.blue),
      body: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Image.asset(
                    property.imagePath.toString(),
                    height: 320,
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
                      property.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.location,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Price: R${property.price}",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Icon(
                              Icons.king_bed,
                              size: 28,
                              color: Colors.blueGrey,
                            ),
                            Text(" ${property.bedrooms} Beds"),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.bathtub,
                              size: 28,
                              color: Colors.blueGrey,
                            ),
                            Text(" ${property.bathrooms} Baths"),
                          ],
                        ),
                        Column(
                          children: [
                            Icon(
                              Icons.square_foot,
                              size: 28,
                              color: Colors.blueGrey,
                            ),
                            Text(" ${property.size} m\u00B2"),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(property.desciption),
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Real Estate', home: HomeScreen());
  }
}

import 'package:clima/types/shop.dart';
import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  List<Shop> _generateMedicalShops() {
    return [
      Shop(
          name: 'Healthy Pharmacy',
          description: 'Your one-stop shop for all your medical needs.',
          address: "Chuy 5",
          image:
              "images/shop1.jpeg"),
      Shop(
          name: 'Wellness Drugstore',
          description: 'Providing quality medicines and healthcare products.',
          address: "Logvinenko 12",
          image:
              'images/shop2.jpeg'),
      Shop(
          name: 'Care Pharmacy',
          address: "10 microdisctirct",
          description:
              'Caring for your health with our wide range of products.',
          image:
              'images/shop3.jpeg'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    List<Shop> medicalShops = _generateMedicalShops();
    return Scaffold(
      appBar: AppBar(title: const Text('List of shops')),
      body: Container(
        child: ListView.builder(
          itemCount: medicalShops.length,
          itemBuilder: (context, index) {
            final shop = medicalShops[index];
            return Card(
              child: Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Image.asset(
                      shop.image,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      shop.name,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    Text(shop.description),
                    const SizedBox(height: 20),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Icon(Icons.place_rounded),
                          Text(shop.address)
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

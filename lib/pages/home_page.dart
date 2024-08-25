import 'dart:convert';

import 'package:ecom_assignment/models/products_model.dart';
import 'package:ecom_assignment/pages/single_product_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as httpClient;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String url = 'https://dummyjson.com/products';
  late Future<ProductsModel> productsModel;

  @override
  void initState() {
    super.initState();
    productsModel = getData();
  }

  Future<ProductsModel> getData() async {
    var response = await httpClient.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print(response.body);
      var data = jsonDecode(response.body);
      return ProductsModel.fromJson(data);
    } else {
      return ProductsModel(); // This should initialize with an empty state
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff5f5f5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Products'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 8,
          right: 16,
          left: 16,
        ),
        child: FutureBuilder<ProductsModel>(
          future: productsModel,
          builder: (context, snapshot) {
            // Check if the snapshot has data and is not null
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.products != null) {
              return ListView.builder(
                itemCount: snapshot.data!.products!.length,
                itemBuilder: (context, index) {
                  var product = snapshot.data!.products![index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SingleProductPage(
                              title: product.title!,
                              description: product.description!,
                              imgSrc: product.images![0],
                              price: product.price,
                              discount: product.discountPercentage,
                            ),
                          ));
                    },
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.network(
                              product.images!.first,
                              height: 100,
                              width: 100,
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title ?? 'Unknown Product',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  Text(
                                    product.description!,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: 16),
                            Column(
                              children: [
                                Text(
                                  '${product.discountPercentage} %off',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red),
                                ),
                                Text(
                                  '\$${product.price}',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text('No products available'));
            }
          },
        ),
      ),
    );
  }
}
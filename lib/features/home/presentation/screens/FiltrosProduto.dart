import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crud_mobile_grafica/features/products/models/produto.dart';

class ProdutoApi {
  const ProdutoApi();

  // URL base ou endpoint direto da sua API no Render
  static const String _url = 'https://crud-grafica-mobile-back.onrender.com/produtos';

  Future<List<Produto>> listarProdutos() async {
    final response = await http.get(Uri.parse(_url));

    if (response.statusCode == 200) {
      // Decodifica o JSON retornado pela API
      List<dynamic> body = jsonDecode(response.body);
      
      // Converte cada item da lista JSON em um objeto Produto
      return body.map((dynamic item) => Produto.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar produtos (Status: ${response.statusCode})');
    }
  }
}
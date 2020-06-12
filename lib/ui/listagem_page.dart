import 'package:disk_tudo/ui/home_page.dart' as home_page;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

var comecou = false;
var criouLista = false;
var tamanho;

final empresasDesc = List();
final empresasCont = List();
final empresasTel = List();
final empresasId = List();

var empresasGeral = List();

Future<Map> getData(int cidadeId, int segmentoId) async {
  var request = "http://192.168.100.35:8087/api/private/Empresa/findByCidadeOuSegmento?cidadeId=$cidadeId&segmentoId=$segmentoId";
  int i = 0;
  http.Response response = await http.get(request);
  //print(json.decode(response.body));
  /*while (i < json.decode(response.body)["numberOfElements"] && criouLista == false) {
    empresasId.add(json.decode(response.body)["content"][i]["id"]);
    empresasDesc.add(json.decode(response.body)["content"][i]["descricao"]);
    empresasCont.add(json.decode(response.body)["content"][i]["contato"]);
    empresasTel.add(json.decode(response.body)["content"][i]["fone"]);
    i++;
  }*/
  empresasGeral = json.decode(response.body)["content"];
  tamanho = json.decode(response.body)["numberOfElements"];

  criouLista = true;
  return json.decode(response.body);
}

class Listagem extends StatefulWidget {
  final String segmento;
  var cidadeId;
  var segmentoId;
  var tam;

  Listagem(this.segmento, this.cidadeId, this.segmentoId);

  @override
  _ListagemState createState() => _ListagemState();
}

class _ListagemState extends State<Listagem> {
  var cidadeIndex;
  var segmentoIndex;
  var qtd;
  var empresas = {};
  var _selecionado = List();

  void ligarItem(int i) {
    print("Ligando pro item $i");
    launch("tel:16991390578");
  }

  animateContainer (int i) {
    setState(() {
      for (int j = 0; j < qtd; j++) {
        if (_selecionado[j]) {
          if (j == i-1) {
            _selecionado[j] = false;
            return;
          }
          _selecionado[j] = false;
        }
      }
      _selecionado[i-1] = !_selecionado[i-1];
    });
  }

  List<Widget> buildItems(AsyncSnapshot snapshot) { // nn ta atualizando essa porra
    print("Snapshot é ${snapshot.data}");
    final itemNome = List();
    final itemContato = List();
    int indexItem = 0;
    qtd = 0;
    //final tam = snapshot.data["numberOfElements"];
    //final qtdItem = snapshot.data["numberOfElements"];

    //while (snapshot.data["content"][indexItem]["id"] != null) {

    while (qtd + 1 <= tamanho) {
      //itemNome.add(snapshot.data["content"][indexItem]["descricao"]); // FAZER O MSM Q FIZ COM O TAMANHO
      //itemContato.add(snapshot.data["content"][indexItem]["contato"]);
      itemNome.add(empresasGeral[indexItem]["descricao"]);
      itemContato.add(empresasGeral[indexItem]["contato"]);
      print(itemNome[indexItem]);
      print(itemContato[indexItem]);

      print('checkpoint 3');
      print(itemNome);

      if (qtd + 1 < tamanho)indexItem++;

      print('checkpoint 4');

      qtd += 1;

      print('checkpoint 5');

    }
    print('checkpoint 6');


    indexItem = 0;

    /*for (int i = 0; i < qtdItem; i++) {
    }*/

    List<Widget> lista = List();

    for (int j = 1; j <= qtd; j++){
      _selecionado.add(false);

      lista.add(
          InkWell(
              onTap: () {animateContainer(j);},
              child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: _selecionado[j-1] ? 94.0 : 64.0,
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
                  padding: EdgeInsets.only(left: 25.0, top: 0.0, right: 15.0),
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget> [
                              AnimatedDefaultTextStyle(
                                style: _selecionado[j-1] ? TextStyle(
                                    fontSize: 24.0,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold
                                ) : TextStyle(
                                    fontSize: 18.0,
                                    color: Colors.black
                                ),
                                duration: Duration(milliseconds: 200),
                                //child: Text("${empresasDesc[j-1]} |${widget.cidadeId}|${widget.segmentoId}"),
                                child: Text("${itemNome[indexItem]}"),
                              ),
                              AnimatedDefaultTextStyle(
                                style: _selecionado[j-1] ? TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.black,
                                ) : TextStyle(
                                    fontSize: 0.0,
                                    color: Colors.black
                                ),
                                duration: Duration(milliseconds: 200),
                                child: Text("Contato: ${itemContato[indexItem]}"),
                              ),
                            ]
                        ),
                        Visibility(
                            visible: _selecionado[j-1] ? true : false,
                            child: IconButton(
                              iconSize: _selecionado[j-1] ? 40.0 : 0.0,
                              enableFeedback: false,
                              icon: Icon(Icons.phone, ),
                              color: Colors.green,
                              onPressed: () {if (_selecionado[j-1]) ligarItem(j);},
                            )
                        )
                      ]
                  )
              )
          )
      );
      print("checkpoint 7 qtd: $qtd index: $indexItem");
      if (indexItem < qtd - 1) indexItem += 1;
      print("checkpoint 8 qtd: $qtd index: $indexItem");
    }
    lista.add(Container(
      height: 0.5,
      color: Colors.black,
    ));

    print('checkpoint 9');


    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.only(left: 15.0),
          ),
          title: Text(widget.segmento, style: TextStyle(color: Colors.white),),
          centerTitle: false,
        ),
        body: FutureBuilder(
          future: getData(widget.cidadeId, widget.segmentoId),
          builder: (context, snapshot) {
            if (comecou == false) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return Center(
                      child: Text("Carregando dados...",
                        style: TextStyle(color: Colors.cyan[800]),)
                  );
                default:
                if (snapshot.hasError) {
                      return Center(
                          child: Text("Erro ao carregar dados... :(", style: TextStyle(color: Colors.cyan[800]),)
                      );
                    } else {
                  comecou = true;
                  criouLista = true;

                  return Container(
                      child: ListView(
                          scrollDirection: Axis.vertical,
                          children: buildItems(snapshot)
                      )
                  );
              }
              }
            } else {
              return Container(
                  child: ListView(
                    scrollDirection: Axis.vertical,
                    children: buildItems(snapshot),
                  )
              );
            }
          }

        )
    );
  }
}


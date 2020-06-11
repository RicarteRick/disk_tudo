import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:disk_tudo/ui/home_page.dart' as home_page;
import 'package:disk_tudo/ui/listagem_page.dart' as listagem_page;
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const request = "http://192.168.100.31:8087/api/private/Cidade/findAll";

var cidades = List();
var comecou = false;
var criouLista = false;
var qtdCidades = 0;
var carregouLista = false;

Future<Map> getData() async {
  int i = 0;
  http.Response response = await http.get(request);
  int tam;
  //print(json.decode(response.body));
  while (json.decode(response.body)[i]["id"] != null && criouLista == false) {
    cidades.add(json.decode(response.body)[i]["descricao"]);
    i++;
    qtdCidades++;
  }
  criouLista = true;
  return json.decode(response.body);
}


class EscolhaCidade extends StatefulWidget {
  @override
  _EscolhaCidadeState createState() => _EscolhaCidadeState();
}

class _EscolhaCidadeState extends State<EscolhaCidade>{

  var qtd;
  var selecionadaIndex = 0;
  var selecionadaName;

  Map<int, String> cidade;

  save() async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('data', selecionadaIndex);
    await prefs.setString('dataNomeCidade', selecionadaName);
  }

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getInt('data');
    var index;

    index = prefs.getInt('data') ?? 0;

    selecionadaIndex = index;
  }

  _EscolhaCidadeState() {
    load();
    home_page.carregou = false;
  }

  escolheCidade (int index) {
    setState(() {
      selecionadaIndex = index;
    });
    save();
    carregouLista = false;
    home_page.carrega();
    //home_page.criouLista = false;
  }

  List<Widget> buildCidades() {
    qtd = cidades.length;

    selecionadaName = cidades[selecionadaIndex];
    List<Widget> lista = List();
    lista.add(
      Container(
        height: 30,
        decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5), color: Colors.cyan[900]),
        padding: EdgeInsets.only(left: 25.0, top: 5.0, right: 15.0),
        child: Text("Selecionada", style: TextStyle(fontSize: 18, color: Colors.white),),
      ),
    );

    lista.add(
        Container(
          padding: EdgeInsets.only(left: 25.0, top: 21.0, right: 15.0),
          height: 64,
          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5)),
          child: Text(selecionadaName, style: TextStyle(fontSize: 18),),
            //contentPadding: EdgeInsets.only(left: 25.0),
        )
    );

    lista.add(
        Container(
          height: 30,
          decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5), color: Colors.cyan[900]),
          padding: EdgeInsets.only(left: 25.0,  top: 5.0, right: 15.0),
          child: Text("Disponíveis (toque para selecionar)", style: TextStyle(fontSize: 18, color: Colors.white),),
        )
    );

    for (int j = 0; j < qtd; j++) {
      lista.add(

          InkWell(
              onTap: () {
                escolheCidade(j);
              },
              child: Container(
                  height: 64,
                  padding: EdgeInsets.only(
                      left: 25.0, top: 21.0, right: 15.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5)),
                  child: Text(
                      cidades[j].toString(), style: TextStyle(fontSize: 18))
              )
          )
      );
    }

    lista.add(Container(
      height: 0.5,
      color: Colors.black,
    ));

    print("qtd: $qtd");
    qtd = 0;
    print("qtd: $qtd");

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.pushReplacement(context,
            Transicao(builder: (context) => home_page.Home())
        );
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () {
                home_page.carrega();
                Navigator.pushReplacement(context,
                    Transicao(builder: (context) => home_page.Home())
                );
                //Navigator.pop(context, false);
              },
              padding: EdgeInsets.only(left: 15.0),
            ),
            title: Text("Cidades", style: TextStyle(color: Colors.white),),
            centerTitle: false,
          ),
          body: FutureBuilder(
            future: getData(),
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
                  /*if (snapshot.hasError) {
                      return Center(
                          child: Text("Erro ao carregar dados... :(", style: TextStyle(color: Colors.cyan[800]),)
                      );
                    } else {*/
                    comecou = true;
                    criouLista = true;

                    return Container(
                        child: ListView(
                            scrollDirection: Axis.vertical,
                            children: buildCidades()
                        )
                    );
                //}
                }
              } else {
                return Container(
                    child: ListView(
                        scrollDirection: Axis.vertical,
                        children: buildCidades()
                    )
                );
              }
            },
            /*child: Container(
                child: ListView(
                  scrollDirection: Axis.vertical,
                  children: buildCidades()
                )
            ),*/
          )),
    );
  }
}

class Transicao extends MaterialPageRoute {
  Transicao({ WidgetBuilder builder, RouteSettings settings })
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    if (settings.name == "home_page.Home()")
      return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return new FadeTransition(opacity: animation, child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    )
    );
  }
}
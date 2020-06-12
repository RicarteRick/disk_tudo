import 'package:disk_tudo/ui/listagem_page.dart' as listagem_page;
import 'package:disk_tudo/ui/cidades_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const requestSegmentos = "http://192.168.100.35:8087/api/private/Segmento/findAll";
const requestCidades = "http://192.168.100.35:8087/api/private/Cidade/findAll";
final cidades = List();
final cidadesId = List();
final segmentos = List();
final segmentosId = List();

var criouLista = false;
var qtdSegmentos = 0;
var comecou = false;
var carregou = false;

Future<Map> getCidades() async {
  int i = 0;
  http.Response response = await http.get(requestCidades);
  //print(json.decode(response.body));
  while (json.decode(response.body)[i]["id"] != null) {
    cidades.add(json.decode(response.body)[i]["descricao"]);
    cidadesId.add(json.decode(response.body)[i]["id"]);
    i++;
  }
  return json.decode(response.body);
}

Future<Map> getSegmentos() async {
  int i = 0;
  http.Response response2 = await http.get(requestSegmentos);
  //print(json.decode(response.body));
  while (json.decode(response2.body)[i]["id"] != null && criouLista == false) {
    segmentos.add(json.decode(response2.body)[i]["descricao"]);
    segmentosId.add(json.decode(response2.body)[i]["id"]);
    i++;
    qtdSegmentos++;
    print("qtdSegmentos: $qtdSegmentos");
  }
  criouLista = true;
  return json.decode(response2.body);
}

carrega() async {
  _HomeState().load();
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int selecionadaIndex;

  var qtd;

  Future load() async {
    var prefs = await SharedPreferences.getInstance();
    var data = prefs.getInt('data');
    var index;

    index = prefs.getInt('data') ?? 0;

    setState(() {
      selecionadaIndex = index;
    });
  }

  _HomeState() {
    load();
  }

  List<Widget> buildSegmentos() {
    qtd = segmentos.length;

    /*
    LISTA DE ÍCONES (SEGMENTOS):
    0 - PIZZARIAS
    1 - SUPERMERCADOS
    2 - MERCADOS
    3 - DROGARIAS
    */
    List<IconData> icones = [Icons.local_pizza, Icons.local_grocery_store, Icons.store, Icons.local_pharmacy];

    List<Widget> lista = List();

    lista.add(
        Container(
          height: 0.5,
          color: Colors.black,
        )
    );

    for (int i = 0; i < 4; i++) {
      lista.add(
        GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => listagem_page.Listagem(segmentos[i], cidadesId[selecionadaIndex], i + 1))
              );
            },
            child: Container(
                height: 64.0,
                decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5), color: Colors.cyan[800]),
                padding: EdgeInsets.only(left: 0.0, top: 5.0, right: 15.0),
                child: ListTile(
                  leading: Icon(icones[i], size: 40, color: Colors.white,),
                  title: Text("${segmentos[i]}", style: TextStyle(fontSize: 18, color: Colors.white),),
                )
            )
        ),
      );
    }

    lista.add(
        Container(
          height: 0.5,
          color: Colors.black,
        )
    );

    print("qtd: $qtd");
    print("seg tamanho: ${segmentos.length}");

    return lista;
  }

  @override
  Widget build(BuildContext context) {
    if (carregou == false) {
      carregou = true;
      load();
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            Container(
              height: 80,
              child: DrawerHeader(
                //padding: EdgeInsets.only(left: 20.0, top: 35.0, right: 15.0),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("DiskTudo  ", style: TextStyle(fontSize: 30, color: Colors.white),),
                      Icon(Icons.android, color: Colors.cyan[800], size: 30,)
                    ],
                ),
                decoration: BoxDecoration(
                  color: Colors.purple[800],
                ),
              ),
            ),
            FutureBuilder(
              future: getCidades(),
              builder: (context, snapshot) {
                return ListTile(
                  leading: Icon(Icons.location_city, size: 30,),
                  title: Text("Cidade", style: TextStyle(fontSize: 18),),
                  subtitle: Text(cidades[selecionadaIndex]),
                  onTap: () {
                    Navigator.pushReplacement(context,
                        Transicao(builder: (context) => EscolhaCidade())
                    );
                  },
                  trailing: Icon(Icons.settings, size: 30),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, size: 30, ),
          onPressed: () {
            carrega();
            _scaffoldKey.currentState.openDrawer();
          },
          padding: EdgeInsets.only(left: 15.0),
        ),
        title: Row(children: <Widget>[
          Text("DiskTudo", style: TextStyle(color: Colors.white),),
          Container(
            width: 219,
          
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
              Icon(Icons.location_city, size: 16),
              Text(" ${cidades[selecionadaIndex]}", style: TextStyle(fontSize: 14, color: Colors.white),)
            ],),
          ),
        ],),
        //title: Text("DiskTudo", style: TextStyle(color: Colors.white),),
        centerTitle: false,
      ),
      body: FutureBuilder(
        future: getSegmentos(),
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
                comecou = true;
                criouLista = true;

                return Container(
                  child: ListView(
                      children: buildSegmentos()
                  ),
                );
            }
          } else {
            return Container(
              child: ListView(
                  children: buildSegmentos()
              ),
            );
          }
        },
      ),
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
    if (settings.name == "EscolhaCidade()")
      return child;
    // Fades between routes. (If you don't want any animation,
    // just return child.)
    return new FadeTransition(opacity: animation, child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      )
    );
  }
}
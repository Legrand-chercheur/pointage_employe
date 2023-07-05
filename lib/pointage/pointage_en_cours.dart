import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Pointage extends StatefulWidget {
  const Pointage({super.key});

  @override
  State<Pointage> createState() => _PointageState();
}

class _PointageState extends State<Pointage> {

  String? id;
  String? nom;
  String? prenom;
  String? photo;

  String heure_arrive = "";
  String? temps_pointages;
  String autres = '';

  void session() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      id = prefs.getString('id');
      nom = prefs.getString('nom');
      prenom = prefs.getString('prenom');
      photo = prefs.getString('photo');
    });
  }

  void pointage_en_cours() async{
    final uri = Uri.parse('http://lea241.alwaysdata.net/pointage/controller_api.php');
    var reponse = await http.post(uri, body: {
      'clic': 'pointage_en_cours',
      'EmployeId': id,
    });
    print(reponse.body);
    if(reponse.body == "Fin de journee"){
      setState(() {
        autres = "Fin de journee";
      });
    }else if(reponse.body == "Pointage non debute"){
      setState(() {
        autres = "Pointage non debute";
      });
    }else {
      var datas = reponse.body.split(',');
      setState(() {
        temps_pointages = datas[0];
        heure_arrive = datas[1];
        print(temps_pointages);
      });
    }

  }

  void Deconnexion() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() async{
      await prefs.remove('id');
      await prefs.remove('nom');
      await prefs.remove('prenom');
      await prefs.remove('photo');
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    session();
  }
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    session();
    pointage_en_cours();
    String formattedTime = "";
    if (temps_pointages != null) {
      int hours = int.parse(temps_pointages!) ~/ 60;
      int minutes =  int.parse(temps_pointages!)  % 60;
      formattedTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/cover.png'),
            fit: BoxFit.cover
          )
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: size.width/1.1,
              height: size.height/2.3,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: autres == ''
                  ?Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Track en cours', style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28
                  ),),
                  Text('13 decembre 2023', style: TextStyle(
                      fontSize: 18
                  ),),
                  Text('Young & Free'),
                  SizedBox(height: 15,),
                  Container(
                    height: 70,
                    width: size.width/1.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.blue,
                        width: 1.3
                      )
                    ),
                    child: Center(
                      child: Text(formattedTime, style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28
                      ),),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text('Heure du pointage : '+heure_arrive, style: TextStyle(
                      fontSize: 16
                  ),),
                ],
              )
                  :Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          width: 160,
                          height: 160,
                          child: Lottie.asset('images/time.json',repeat: true),
                      ),
                      Text(autres,style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                      ),),
                    ],
                  ),
            ),
            SizedBox(height: 10,),
            Container(
              width: size.width/1.1,
              height: size.height/2.8,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                children: [
                  SizedBox(width: 10,),
                  Container(
                    width: size.width/2,
                    height: size.height/3,
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                            image: NetworkImage('http://192.168.100.75:5000/'+photo!),
                          fit: BoxFit.cover
                        )
                    ),
                  ),
                  SizedBox(width: 20,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nom',style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),),
                      Text(nom!),
                      Text('Prenom',style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),),
                      Text(prenom!),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 10,),
            GestureDetector(
              onTap: () {
                Deconnexion();
              },
              child: Container(
                width: size.width/1.1,
                height: 60,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Center(
                  child: Text('Deconnexion', style: TextStyle(
                    color: Colors.white
                  ),),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

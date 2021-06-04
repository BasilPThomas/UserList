import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage ({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List users = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    this.fetchUser();
  }
  fetchUser() async {
    setState(() {
      isLoading = true;
    });
    final response =
    await http.get(Uri.parse("https://reqres.in/api/users?page=2"));
    if(response.statusCode == 200){
      var items = json.decode(response.body)['data'];
      setState(() {
        users = items;
        isLoading = false;
      });
    }else{
      users = [];
      isLoading = false;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listing Users"),
      ),
      body: getBody(),
    );
  }
  Widget getBody(){
    if(users.contains(null) || users.length < 0 || isLoading){
      return Center(child: CircularProgressIndicator());
    }else {
      return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            // return getCard(users[index]);
            return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                setState(() {
                  users.removeAt(index);
                });
              },
              child: getCard(users[index]),
              background: Container(
                color: Colors.red,
                margin: EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            );
          });
    }
  }
  Widget getCard(items){
    var fullName = items['first_name']+" "+items['last_name'];
    var email = items['email'];
    var profileUrl = items['avatar'];
    return Card(
            elevation: 2.5,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListTile(
                title: Row(
                  children: <Widget>[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60/2),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(profileUrl)
                          )
                      ),
                    ),
                    SizedBox(width: 20,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                            width: MediaQuery.of(context).size.width-140,
                            child: Text(fullName,style: TextStyle(fontSize: 17),)),
                        SizedBox(height: 10,),
                        Text(email.toString(),style: TextStyle(color: Colors.grey),)
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
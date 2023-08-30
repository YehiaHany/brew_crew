import 'package:crew_brew/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../services/database.dart';
import '../../shared/loading.dart';

class SettingsForm extends StatefulWidget {
  @override
  _SettingsFormState createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {

  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  // form values
  String _currentName = '';
  String _currentSugars = '0';
  int _currentStrength = 100;
  bool name=false;
  bool sugar=false;
  bool strength=false;
  int c=1;
  // late String _currentName ;
  // late String _currentSugars ;
  // late int _currentStrength ;

  @override
  Widget build(BuildContext context) {
    Users user = Provider.of<Users>(context);



    return StreamBuilder<UserData>(
        stream: DatabaseService(uid: user.uid).userData,
        builder: (context, snapshot) {
          if(snapshot.hasData){
            UserData? userData = snapshot.data;
            if(c==1){
              _currentStrength=userData!.strength;
              c=0;
            }
            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    'Update your brew settings.',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: userData?.name,
                    decoration: textInputDecoration,
                    validator: (val) => val!.isEmpty ? 'Please enter a name' : null,
                    onChanged: (val) {
                      setState(() {
                        _currentName=val;
                        name=true;
                      });
                    },
                  ),
                  SizedBox(height: 10.0),
                  DropdownButtonFormField(
                    value: userData?.sugars,
                    decoration: textInputDecoration,
                    items: sugars.map((sugar) {
                      return DropdownMenuItem(
                        value: sugar,
                        child: Text('$sugar sugars'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _currentSugars=val!;
                        sugar=true;
                      });
                    },
                  ),

                  // DropdownButtonFormField(
                  //   decoration: textInputDecoration.copyWith(fillColor:Colors.white38),
                  //   items: sugars.map( (sugar) {
                  //     return DropdownMenuItem(
                  //         value: sugar,
                  //         child: Text('$sugar sugars ') );
                  //   } ).toList(),
                  //   onChanged: (value) {
                  //     setState( () => _currentSugars = value as String );
                  //   },
                  // ),

                  SizedBox(height: 10.0),
                  Slider(
                    value: (_currentStrength ?? userData?.strength)!.toDouble(),
                      activeColor: Colors.brown[_currentStrength ?? 100],
                    inactiveColor: Colors.brown[_currentStrength ?? 100],
                    min: 100.0,
                    max: 900.0,
                    divisions: 8,
                    onChanged: (val){
                      setState(() {
                        _currentStrength=val.round();
                        strength=true;
                      });
                    }
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[400],
                      ),
                      child: Text(
                        'Update',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        if(name==false){
                          _currentName=userData!.name;
                        }
                        if(sugar==false){
                          _currentSugars=userData!.sugars;
                        }

                        if(_formKey.currentState!.validate()){
                          await DatabaseService(uid: user.uid).updateUserData(
                              _currentSugars ?? snapshot.data!.sugars,
                              _currentName ?? snapshot.data!.name,
                              _currentStrength ?? snapshot.data!.strength
                          );
                          Navigator.pop(context);
                        }
                      }
                  ),
                ],
              ),
            );
          } else {
            return Loading();
          }
        }
    );
  }
}





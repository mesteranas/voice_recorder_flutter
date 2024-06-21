import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'settings.dart';
import 'package:flutter/widgets.dart';

import 'language.dart';
import 'package:http/http.dart' as http;
import 'viewText.dart';
import 'app.dart';
import 'contectUs.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async{
  await WidgetsFlutterBinding.ensureInitialized();
  await Language.runTranslation();
  runApp(test());
}
class test extends StatefulWidget{
  const test({Key?key}):super(key:key);
  @override
  State<test> createState()=>_test();
}
class _test extends State<test>{
  var paused=false;
  var _recorder=Record();
  String path="";
  var isRecording=false;
  var _=Language.translate;
  _test();
  void initState(){
    super.initState();
    _recorder=Record();

  }
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      locale: Locale(Language.languageCode),
      title: App.name,
      themeMode: ThemeMode.system,
      home:Builder(builder:(context) 
    =>Scaffold(
      appBar:AppBar(
        title: const Text(App.name),), 
        drawer: Drawer(
          child:ListView(children: [
          DrawerHeader(child: Text(_("navigation menu"))),
          ListTile(title:Text(_("settings")) ,onTap:() async{
            await Navigator.push(context, MaterialPageRoute(builder: (context) =>SettingsDialog(this._) ));
            setState(() {
              
            });
          } ,),
          ListTile(title: Text(_("contect us")),onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>ContectUsDialog(this._)));
          },),
          ListTile(title: Text(_("donate")),onTap: (){
            launch("https://www.paypal.me/AMohammed231");
          },),
  ListTile(title: Text(_("visite project on github")),onTap: (){
    launch("https://github.com/mesteranas/"+App.appName);
  },),
  ListTile(title: Text(_("license")),onTap: ()async{
    String result;
    try{
    http.Response r=await http.get(Uri.parse("https://raw.githubusercontent.com/mesteranas/" + App.appName + "/main/LICENSE"));
    if ((r.statusCode==200)) {
      result=r.body;
    }else{
      result=_("error");
    }
    }catch(error){
      result=_("error");
    }
    Navigator.push(context, MaterialPageRoute(builder: (context)=>ViewText(_("license"), result)));
  },),
  ListTile(title: Text(_("about")),onTap: (){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(title: Text(_("about")+" "+App.name),content:Center(child:Column(children: [
        ListTile(title: Text(_("version: ") + App.version.toString())),
        ListTile(title:Text(_("developer:")+" mesteranas")),
        ListTile(title:Text(_("description:") + App.description))
      ],) ,));
    });
  },)
        ],) ,),
        body:Container(alignment: Alignment.center
        ,child: Column(children: [
          ElevatedButton(onPressed: () async{
            var result=await FilePicker.platform.getDirectoryPath();
            if (result!=""){
              path=result??"";
              path += "/recording.mp3";
              setState(() {
                
              });
            }
          }, child: Text(_("select file"))),
              if (path.isNotEmpty && !isRecording)
                IconButton(
                  onPressed: () async {
                      await Permission.microphone.request();
                      await _recorder.start(path: path,encoder: AudioEncoder.AAC,    bitRate: 128000,  samplingRate: 44100, );
                      setState(() {
                        isRecording = true;
                        paused=false;
                      });
                  },
                  icon: Icon(Icons.mic),
                  tooltip: _("record"),
                )
                
              else if (path.isNotEmpty && isRecording)
              Column(children: [
              if (paused==false)
              ElevatedButton(onPressed: (){
                _recorder.pause();
                setState(() {
                  paused=true;
                });
              }, child: Text(_("pause")))
              else
              ElevatedButton(onPressed: (){
                _recorder.resume();
                setState(() {
                  paused=false;
                });
              }, child: Text(_("resume"))),
                IconButton(
                  onPressed: () async {
                    try {
                      await _recorder.stop();
                      setState(() {
                        isRecording = false;
                        paused=false;
                      });
                    } catch (e) {
                      print('Error stopping recorder: $e');
                    }
                  },
                  icon: Icon(Icons.stop),
                  tooltip: _("stop"),
                ),
              ]),
    ])),)));
  }
}

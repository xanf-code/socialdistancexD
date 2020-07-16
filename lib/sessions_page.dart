import 'main.dart';
import 'session.dart';
import 'package:flutter/material.dart';

class SessionsPage extends StatefulWidget {
  @override
  _SessionsPageState createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  @override
  Widget build(BuildContext context) {

    List<Widget> sessions = List();
    int numSessions = sharedPreferences.getInt('sessions') ?? 0;

    debugPrint('numSessions: $numSessions');

//    sessions.add(RaisedButton(
//      child: Text('clear'),
//      onPressed: () {
//        sharedPreferences.setInt('sessions', null);
//        debugPrint('succ');
//      },
//    ));

    for(int i = 1; i <= numSessions; i++) {
      Session s = Session();
      s.deviceIds = sharedPreferences.getStringList('ids_$i');
      s.strTimes = sharedPreferences.getStringList('times_$i');
      sessions.add(SessionWidget(s));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Sessions'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Center(
          child: numSessions == 0 ? Text('No sessions yet.') : ListView(
            shrinkWrap: true,
            children: sessions,
          ),
        ),
      ),
    );
  }
}

class SessionWidget extends StatefulWidget {

  final Session session;
  SessionWidget(this.session);

  @override
  _SessionWidgetState createState() => _SessionWidgetState();
}

class _SessionWidgetState extends State<SessionWidget> {

  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red, width: 5),
        borderRadius: BorderRadius.circular(4)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: getContent(),
      ),
      onTap: () => setState(() {
        expanded = !expanded;
      }),
    );
  }

  Widget getContent() {
    if(!expanded) return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text('Session from ${widget.session.strTimes[0]}'),
        Icon(Icons.arrow_drop_down)
      ],
    );
    else return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.session.deviceIds.length + 1,
      itemBuilder: (ctx, index) {
        if(index == 0) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(),
              Icon(Icons.arrow_drop_up)
            ],
          );
        } else index--;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('detected device COVID19-${widget.session.deviceIds[index]}'),
            Text('at ${widget.session.strTimes[index]}')
          ],
        );
      },
    );
  }
}


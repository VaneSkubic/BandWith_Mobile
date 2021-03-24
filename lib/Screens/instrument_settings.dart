import 'package:flutter/material.dart';
import '../Providers/auth.dart';
import '../Providers/settings.dart';
import '../Screens/empty_page.dart';
import 'package:provider/provider.dart';

dynamic settings;

class InstrumentSettings extends StatefulWidget {
  static const routeName = '/instrumentSettings';

  @override
  _InstrumentSettingsState createState() => _InstrumentSettingsState();
}

class _InstrumentSettingsState extends State<InstrumentSettings> {
  Future getInstruments;
  dynamic settings;
  dynamic auth;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      auth = Provider.of<Auth>(context, listen: false);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      settings = Provider.of<Settings>(context, listen: false);
      setState(() {
        getInstruments = settings.getInstruments(auth.token);
      });
      getInstruments = settings.getInstruments(auth.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<Settings, Auth>(
      builder: (ctx, settings, auth, _) => FutureBuilder(
        future: getInstruments,
        builder: (ctx, settingsResultSnapshot) =>
            (settingsResultSnapshot.connectionState == ConnectionState.waiting)
                ? EmptyPage()
                : InstrumentsPage(),
      ),
    );
  }
}

class InstrumentsPage extends StatefulWidget {
  @override
  _InstrumentsPageState createState() => _InstrumentsPageState();
}

class _InstrumentsPageState extends State<InstrumentsPage> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context, listen: false);
    final settings = Provider.of<Settings>(context, listen: false);
    dynamic userInstruments = Provider.of<Settings>(context).userInstruments;
    dynamic filteredInstruments = [];
    if (userInstruments != null) {
      userInstruments.forEach((key, value) {
        if (value != 0) {
          filteredInstruments.addAll(
            {key},
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                Icons.save_outlined,
              ),
              onPressed: () {
                settings.updateInstruments(auth.token, userInstruments);
              },
            ),
          ),
        ],
        elevation: 0,
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'Montserrat',
              fontSize: 20,
              letterSpacing: 4,
            ),
            children: [
              TextSpan(
                text: 'Instruments',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10, left: 10),
            alignment: Alignment.topLeft,
            child: TextButton(
              child: Text('+ Add Instrument'),
              onPressed: () {
                dynamic tmp = [];
                userInstruments.forEach(
                  (key, value) {
                    if (!filteredInstruments.contains(key)) tmp.add(key);
                  },
                );
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(10.0),
                      topRight: const Radius.circular(10.0),
                    ),
                  ),
                  builder: (BuildContext context) {
                    return Column(
                      children: [
                        Icon(
                          Icons.horizontal_rule_rounded,
                          size: 30,
                        ),
                        Container(
                          height: 380,
                          child: Center(
                            child: ListView.builder(
                              itemCount: tmp != null ? tmp.length : 0,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  children: [
                                    Divider(
                                      height: 0,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          filteredInstruments.add(tmp[index]);
                                          userInstruments[tmp[index]] = 1;
                                          Navigator.pop(context);
                                        });
                                      },
                                      child: ListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 30),
                                        title: Text(
                                          tmp[index] != null
                                              ? tmp[index].toString()
                                              : 'No instruments',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        leading: tmp[index] != null
                                            ? ImageIcon(AssetImage('Assets/' +
                                                tmp[index]
                                                    .toString()
                                                    .replaceAll('/', '') +
                                                '.png'))
                                            : null,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount:
                  filteredInstruments != null ? filteredInstruments.length : 0,
              itemBuilder: (ctx, index) {
                return Column(
                  children: [
                    Divider(),
                    ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                      title: Text(
                        filteredInstruments[index] != null
                            ? filteredInstruments[index].toString()
                            : 'No instruments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: filteredInstruments[index] != null
                          ? ImageIcon(AssetImage('Assets/' +
                              filteredInstruments[index]
                                  .toString()
                                  .replaceAll('/', '') +
                              '.png'))
                          : null,
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline),
                        onPressed: () {
                          setState(() {
                            userInstruments.forEach((key, value) {
                              if (key == filteredInstruments[index]) {
                                userInstruments[key] = 0;
                              }
                            });
                            filteredInstruments.removeAt(index);
                          });
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import '../Providers/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

final FocusNode _emailFocus = FocusNode();
final FocusNode _passwordFocus = FocusNode();
final FocusNode _nameFocus = FocusNode();
final FocusNode _surnameFocus = FocusNode();
final _emailController = TextEditingController();
final _nameController = TextEditingController();
final _surnameController = TextEditingController();
bool _passwordVisible = false;

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          _emailFocus.unfocus();
          _passwordFocus.unfocus();
          _nameFocus.unfocus();
          _surnameFocus.unfocus();
        },
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(96, 238, 255, 1).withOpacity(0.5),
                    Color.fromRGBO(1, 98, 255, 1).withOpacity(0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 1],
                ),
              ),
            ),
            SingleChildScrollView(
              child: Container(
                height: deviceSize.height,
                width: deviceSize.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10.0, top: 60),
                        padding: EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 50.0),
                        child: Image(
                          image: AssetImage('Assets/Logo.png'),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: deviceSize.width > 600 ? 2 : 2,
                      child: AuthCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  int segmentedControlValue = 0;

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'Name': '',
    'Surname': '',
    'Email': '',
    'Password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An error occured'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['Email'],
          _authData['Password'],
        );
      } else {
        _switchAuthMode();
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['Name'],
          _authData['Surname'],
          _authData['Email'],
          _authData['Password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email adress is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Invalid eMail';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
        //_passwordController.clear();
      } else {
        errorMessage = error.toString();
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage = 'Could not authenticate, please try later';
      _showErrorDialog(errorMessage);
    }
    setState(() {
      _switchAuthMode();
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    _emailFocus.unfocus();
    _passwordFocus.unfocus();
    _nameFocus.unfocus();
    _surnameFocus.unfocus();

    _emailController.clear();
    _passwordController.clear();
    _nameController.clear();
    _surnameController.clear();

    _authMode = segmentedControlValue == 0 ? AuthMode.Login : AuthMode.Signup;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Container(
          width: deviceSize.width * 0.75,
          margin: EdgeInsets.only(
            left: 0,
            top: 15,
            right: 0,
            bottom: 10,
          ),
          padding: EdgeInsets.all(16),
          child: CupertinoSlidingSegmentedControl(
              groupValue: segmentedControlValue,
              backgroundColor: Color.fromRGBO(255, 255, 255, 1).withOpacity(.5),
              children: <int, Widget>{
                0: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    segmentedControlValue == 0 ? 'LOG IN' : 'Log In',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: segmentedControlValue == 0
                          ? FontWeight.w600
                          : FontWeight.normal,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
                1: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    segmentedControlValue == 1 ? 'REGISTER' : 'Register',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: segmentedControlValue == 1
                          ? FontWeight.w600
                          : FontWeight.normal,
                      letterSpacing: 1.6,
                    ),
                  ),
                ),
              },
              onValueChanged: (value) {
                setState(() {
                  segmentedControlValue = value;
                  _switchAuthMode();
                });
              }),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 20.0,
          child: Container(
            height: _authMode == AuthMode.Signup ? 290 : 175,
            width: deviceSize.width * 0.75,
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Offstage(
                      offstage: _authMode == AuthMode.Login ? true : false,
                      child: TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: !_nameFocus.hasPrimaryFocus
                              ? Icon(Icons.account_circle_outlined)
                              : null,
                        ),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Provide a name!';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _authData['Name'] = value.trim();
                        },
                      ),
                    ),
                    Offstage(
                      offstage: _authMode == AuthMode.Login ? true : false,
                      child: TextFormField(
                        controller: _surnameController,
                        focusNode: _surnameFocus,
                        enabled: _authMode == AuthMode.Login ? false : true,
                        decoration: InputDecoration(
                          labelText: 'Surname',
                          prefixIcon: !_surnameFocus.hasPrimaryFocus
                              ? Icon(Icons.text_fields_outlined)
                              : null,
                        ),
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Provide a surname!';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          _authData['Surname'] = value.trim();
                        },
                      ),
                    ),
                    TextFormField(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: !_emailFocus.hasPrimaryFocus
                            ? Icon(Icons.email_outlined)
                            : null,
                      ),
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value.isEmpty || !value.contains('@')) {
                          return 'Invalid eMail!';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _authData['Email'] = value.trim();
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: !_passwordFocus.hasPrimaryFocus
                            ? Icon(Icons.lock_outline)
                            : null,
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),
                          onPressed: () {
                            // Update the state i.e. toogle the state of passwordVisible variable
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_passwordVisible,
                      onChanged: (value) {
                        _authData['Password'] = value;
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: deviceSize.width * 0.55,
          margin: _authMode == AuthMode.Login
              ? EdgeInsets.only(top: 80)
              : EdgeInsets.only(top: 20),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
              primary: Colors.white,
              onPrimary: Colors.black,
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: !_isLoading
                  ? Text(
                      _authMode == AuthMode.Login ? 'LOG IN' : 'REGISTER',
                      style: TextStyle(
                        letterSpacing: 1.6,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Container(
                      //padding: const EdgeInsets.only(top: 80.0),
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.white.withOpacity(0),
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    ),
            ),
            onPressed: _submit,
          ),
        ),
      ],
    );
  }
}

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
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          _emailFocus.unfocus();
          _passwordFocus.unfocus();
          _nameFocus.unfocus();
          _surnameFocus.unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(bottom: 10.0, top: 60),
                  padding:
                      EdgeInsets.symmetric(vertical: 30.0, horizontal: 50.0),
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
        await Provider.of<Auth>(context, listen: false).login(
          _authData['Email'],
          _authData['Password'],
        );
      } else {
        _switchAuthMode();
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

    _authMode = _authMode == AuthMode.Signup ? AuthMode.Login : AuthMode.Signup;
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Column(
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(
              left: 30,
              right: 30,
              top: _authMode == AuthMode.Login ? 30 : 0,
            ),
            child: Column(
              children: <Widget>[
                Offstage(
                  offstage: _authMode == AuthMode.Login ? true : false,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Name',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          cursorColor: Colors.black,
                          controller: _nameController,
                          focusNode: _nameFocus,
                          obscureText: false,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Color(0xfff0f0f0),
                            filled: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Offstage(
                  offstage: _authMode == AuthMode.Login ? true : false,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Surname',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          cursorColor: Colors.black,
                          controller: _surnameController,
                          focusNode: _surnameFocus,
                          obscureText: false,
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Color(0xfff0f0f0),
                            filled: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Email',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        cursorColor: Colors.black,
                        controller: _emailController,
                        focusNode: _emailFocus,
                        obscureText: false,
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
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xfff0f0f0),
                          filled: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Password',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        cursorColor: Colors.black,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xfff0f0f0),
                          filled: true,
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.grey[800],
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _passwordVisible = !_passwordVisible;
                              });
                            },
                          ),
                        ),
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        obscureText: !_passwordVisible,
                        keyboardType: TextInputType.name,
                        onChanged: (value) {
                          _authData['Password'] = value;
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _authMode == AuthMode.Login
                    ? 'New to BandWith?'
                    : 'Already have an account?',
                textAlign: TextAlign.center,
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _switchAuthMode();
                  });
                },
                child: Text(
                  _authMode == AuthMode.Login ? 'Sign Up!' : 'Log In!',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: deviceSize.width * 0.55,
          margin: _authMode == AuthMode.Login
              ? EdgeInsets.only(top: 80, bottom: 40)
              : EdgeInsets.only(top: 20, bottom: 30),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
              primary: Colors.black,
              onPrimary: Colors.white,
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

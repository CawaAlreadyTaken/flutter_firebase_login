import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../main.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:sms_autofill/sms_autofill.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static Map<String, String> userData = {};

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final TextEditingController _phoneNumberController = TextEditingController();
  Session _session = Session();

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(() {
      String text = _phoneNumberController.text;
      text = text.replaceAll('+39', '');
      _phoneNumberController.value = _phoneNumberController.value.copyWith(
        text: text,
        selection:
        TextSelection(baseOffset: text.length, extentOffset: text.length),
        composing: TextRange.empty,
      );
    });
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication,)) {
      throw 'Could not launch $url';
    }
  }

  Future<bool> loginTelegram() async {
    Map<String, String> headers = {
      "Content-Type": "application/x-www-form-urlencoded",
      "origin": "https://oauth.telegram.org",
      "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36",
    };
    String ans = await _session.post(
        "https://oauth.telegram.org/auth/request?bot_id=5699352328&origin=https%3A%2F%2Floginkazoo.cawa.dev&embed=1",
        headers, "phone=39${_phoneNumberController.text}");
    return true;
  }

  Future<bool> checkLogin() async {
    Map<String, String> headers = {
      "Content-length": "0",
      "Content-Type": "application/x-www-form-urlencoded",
      "origin": "https://oauth.telegram.org",
      "user-agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/104.0.0.0 Safari/537.36",
    };
    String ans = await _session.post("https://oauth.telegram.org/auth/login?bot_id=5699352328&origin=https%3A%2F%2Floginkazoo.cawa.dev&embed=1", headers, "");
    return ans=='true';
  }

  Future<bool> getData() async {
    String ans = await _session.get("https://oauth.telegram.org/auth?bot_id=5699352328&origin=https%3A%2F%2Floginkazoo.cawa.dev&embed=1", {});
    try {
      String id = ans.split('"id":')[1].split(',')[0];
      String first_name = ans.split('"first_name":"')[1].split('",')[0];
      String username = ans.split('"username":"')[1].split('",')[0];
      String hash = ans.split('"hash":"')[1].split('"')[0];
      LoginScreen.userData["id"] = id;
      LoginScreen.userData["first_name"] = first_name;
      LoginScreen.userData["username"] = username;
      LoginScreen.userData["hash"] = hash;
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4196E3),
              Color(0xFF373598),
            ],
            begin: Alignment.topLeft,
            end: Alignment.centerRight,
            stops: [0, 0.8],
          ),
        ),
        child: _isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.all(18.0),
                child: Text(
                  'Processing',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              )
            ],
          ),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FlutterLogo(
              size: 150,
            ),
            const SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () async {
                _session = Session();
                return showDialog<void>(
                  context: context,
                  barrierDismissible: false, // user must tap button!
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                          'Inserisci il tuo numero di telefono'),
                      content: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('+39'),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 180,
                              height: 40,
                              child:
                                PhoneFieldHint(
                                  controller: _phoneNumberController,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(10),
                                  ],
                                ),
                            ),
                          ]
                      ),
                      actions: <Widget>[
                        TextButton(
                            child: const Text('Conferma'),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              showDialog<void>(
                                context: context,
                                barrierDismissible: false,
                                // user must tap button!
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Hai confermato l\'accesso via Telegram?'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          bool res1 = await checkLogin();
                                          bool res2 = await getData();
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          //Navigator.of(context).pop();
                                          if (res1 && res2) {
                                            MyApp.telegramStatus.value =
                                                Status.Connected;
                                          } else {
                                            MyApp.telegramStatus.value =
                                                Status.FailedLogin;
                                          }
                                        },
                                        child: const Text('Si'),
                                      ),
                                      const TextButton(
                                        onPressed: null,
                                        child: Text('Non ancora'),
                                      )
                                    ],
                                  );
                                },
                              );
                              loginTelegram();
                              _launchUrl("https://t.me/+42777");
                            }
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                height: 50,
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.telegram,
                      size: 30,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(
                      width: 14,
                    ),
                    const Text(
                      'Login With Telegram',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (MyApp.telegramStatus.value == Status.FailedLogin)
              Text("Login fallito. Prova di nuovo"),
          ],
        ),
      ),
    );
  }
}
class Session {
  String cookies = "";
  Session();

  Future<String> get(String url, Map<String, String> headers) async {
    var uri = Uri.parse(url);
    headers["cookie"] = cookies;
    final response = await http.get(uri, headers: headers);
    print(response.body);
    print(response.headers);
    print(response.headers["set-cookie"]);
    if (response.headers["set-cookie"] != null) {
      cookies = '$cookies${response.headers["set-cookie"]!};';
    }
    return response.body;
  }

  String addCookiesFromCookiesInfo(String cookies, List<String> cookiesInfo) {
    for (String s in cookiesInfo) {
      if (s.split('=').length < 2)
        continue;
      var name = s.split('=')[0];
      if (!(name.contains("path")) && !(name.contains("samesite")) && !(name.contains("secure")) && !(name.contains("expires"))) {
        s = s.replaceAll('HttpOnly,', '');
        cookies = '${cookies}$s;';
      }
    }
    return cookies;
  }

  Future<String> post(String url, Map<String, String> headers, String body) async {
    var uri = Uri.parse(url);
    headers["cookie"] = cookies;
    final response = await http.post(uri, headers: headers, body: body);
    var cookiesInfo = response.headers["set-cookie"]?.split(';');
    if (cookiesInfo != null) {
      cookies = addCookiesFromCookiesInfo(cookies, cookiesInfo);
    }
    print('Cookies: $cookies');
    return response.body;
  }

}

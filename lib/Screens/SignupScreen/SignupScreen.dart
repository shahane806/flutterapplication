import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:sim_card_info/sim_card_info.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sim_card_info/sim_info.dart';

import '../../AlertHandler/snackBarManager.dart';
import '../../StateManagement/SignupStateManagement/SignupBloc/SignupBloc.dart';
import '../../StateManagement/SignupStateManagement/SignupEvent/SignupEvent.dart';
import '../../StateManagement/SignupStateManagement/SignupState/SignupState.dart';
import '../LoginScreen/LoginScreen.dart';
import 'SignupComponents/SignupButton.dart';
import 'SignupComponents/SignupConfirmPasswordField.dart';
import 'SignupComponents/SignupEmailField.dart';
import 'SignupComponents/SignupMobileNumberField.dart';
import 'SignupComponents/SignupPasswordField.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  String _deviceId = '';
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  List<SimInfo>? _simInfo;
  final _simCardInfoPlugin = SimCardInfo();
  bool isSupported = true;
  String _error = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceId();

    initSimInfoState();
  }

  @override
  void dispose() {
    super.dispose();
    _mobileController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailController.dispose();
    _userNameController.dispose();
  }

  Future<void> initSimInfoState() async {
    // Request READ_PHONE_STATE permission
    final phonePermissionStatus = await Permission.phone.request();

    if (phonePermissionStatus.isGranted) {
      List<SimInfo>? simCardInfo;
      try {
        simCardInfo = await _simCardInfoPlugin.getSimInfo() ?? [];
        if (simCardInfo.isEmpty) {
          setState(() {
            _error = 'No SIM card information available';
          });
        }
      } on PlatformException catch (e) {
        simCardInfo = [];
        setState(() {
          isSupported = false;
          _error = 'Platform error: ${e.message}';
        });
      } catch (e) {
        simCardInfo = [];
        setState(() {
          _error = 'Unexpected error: $e';
        });
      }

      if (!mounted) return;

      setState(() {
        _simInfo = simCardInfo;
      });
    } else if (phonePermissionStatus.isDenied) {
      setState(() {
        _error =
            'Phone permission denied. Please grant permission to access SIM info.';
      });
    } else if (phonePermissionStatus.isPermanentlyDenied) {
      setState(() {
        _error =
            'Phone permission permanently denied. Please enable it in settings.';
      });
      await openAppSettings(); // Prompt user to enable in settings
    }
  }

  Future<void> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        print("Android ID: ${androidInfo.id}");
        setState(() {
          _deviceId = androidInfo.id;
        });
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        print("iOS ID: ${iosInfo.identifierForVendor}");
        setState(() {
          _deviceId = iosInfo.identifierForVendor ?? 'Unknown';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error getting device ID: $e';
      });
      print(e);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    });
  }

  String? _emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    return null;
  }

  String _getDialCodeFromCountryIso(String countryIso) {
    try {
      // Find the country in countryList that matches the countryIso (case-insensitive)
      final country = countryList.firstWhere(
        (country) => country.code.toUpperCase() == countryIso.toUpperCase(),
        orElse: () =>
            Country(name: 'Unknown', code: 'XX', dialCode: '+00'), // Fallback
      );
      return country.dialCode;
    } catch (e) {
      // Handle any errors (e.g., if _simInfo is empty or country not found)
      return '+00'; // Default dial code if lookup fails
    }
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return "Confirm Password is required";
    }
    if (value != _passwordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        body: BlocListener<SignupBloc, SignupState>(
          listener: (context, state) {
            if (state.email != null) {
              SnackBarManager.showSuccessSnackBar(
                  context, "Register Successful.");
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            }
          },
          child: Stack(
            children: [
              // Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange,
                      Colors.orangeAccent,
                      Colors.orangeAccent,
                      Color(0xFFF5F5F5),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Signup Title
                        Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: screenWidth * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Please sign up to get started.",
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Email TextField
                        SignupEmailField(
                          controller: _emailController,
                          label: "Email",
                          hint: "Enter your email",
                          inputType: TextInputType.emailAddress,
                          maxLength: null,
                          isObscure: false,
                          validator: _emailValidator,
                        ),
                        const SizedBox(height: 20),

                        // Mobile TextField
                        SignupMobileNumberField(
                          controller: _mobileController,
                          label: "Mobile Number",
                          hint: "Enter your mobile number",
                          inputType: TextInputType.phone,
                          maxLength: 10,
                          isObscure: false,
                          validator: null,
                        ),
                        const SizedBox(height: 20),

                        // Password TextField
                        SignupPasswordField(
                          controller: _passwordController,
                          label: "Password",
                          hint: "Enter Password",
                          isObscure: !_isPasswordVisible,
                          inputType: TextInputType.text,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: _togglePasswordVisibility,
                          ),
                          validator: _passwordValidator,
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password TextField
                        SignupConfirmPasswordField(
                          controller: _confirmPasswordController,
                          label: "Confirm Password",
                          hint: "Re-enter Password",
                          isObscure: !_isConfirmPasswordVisible,
                          inputType: TextInputType.text,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                            onPressed: _toggleConfirmPasswordVisibility,
                          ),
                          validator: _confirmPasswordValidator,
                        ),
                        const SizedBox(height: 30),

                        // Signup Button
                        SignupButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              context.read<SignupBloc>().add(SignupEvent(
                                    email: _emailController.text,
                                    mobile: _mobileController.text,
                                    password: _passwordController.text,
                                    userName: _userNameController.text,
                                    countryCode:
                                        _simInfo!.elementAt(0).countryIso,
                                    dialCode: _getDialCodeFromCountryIso(
                                        _simInfo!.elementAt(0).countryIso),
                                    deviceId: _deviceId,
                                  ));
                              print("Signup Button Clicked");
                            }
                          },
                          label: "Sign Up",
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.07,
                          backgroundColor: Colors.white,
                          textColor: Colors.blue,
                        ),
                        const SizedBox(height: 20),

                        // Footer Text
                        Text(
                          "By signing up, you agree to our Terms & Conditions.",
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: Colors.blue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final List<Country> countryList = [
    Country(name: "Afghanistan", code: "AF", dialCode: "+93"),
    Country(name: "Aland Islands", code: "AX", dialCode: "+358"),
    Country(name: "Albania", code: "AL", dialCode: "+355"),
    Country(name: "Algeria", code: "DZ", dialCode: "+213"),
    Country(name: "American Samoa", code: "AS", dialCode: "+1-684"),
    Country(name: "Andorra", code: "AD", dialCode: "+376"),
    Country(name: "Angola", code: "AO", dialCode: "+244"),
    Country(name: "Anguilla", code: "AI", dialCode: "+1-264"),
    Country(name: "Antarctica", code: "AQ", dialCode: "+672"),
    Country(name: "Antigua and Barbuda", code: "AG", dialCode: "+1-268"),
    Country(name: "Argentina", code: "AR", dialCode: "+54"),
    Country(name: "Armenia", code: "AM", dialCode: "+374"),
    Country(name: "Aruba", code: "AW", dialCode: "+297"),
    Country(name: "Australia", code: "AU", dialCode: "+61"),
    Country(name: "Austria", code: "AT", dialCode: "+43"),
    Country(name: "Azerbaijan", code: "AZ", dialCode: "+994"),
    Country(name: "Bahamas", code: "BS", dialCode: "+1-242"),
    Country(name: "Bahrain", code: "BH", dialCode: "+973"),
    Country(name: "Bangladesh", code: "BD", dialCode: "+880"),
    Country(name: "Barbados", code: "BB", dialCode: "+1-246"),
    Country(name: "Belarus", code: "BY", dialCode: "+375"),
    Country(name: "Belgium", code: "BE", dialCode: "+32"),
    Country(name: "Belize", code: "BZ", dialCode: "+501"),
    Country(name: "Benin", code: "BJ", dialCode: "+229"),
    Country(name: "Bermuda", code: "BM", dialCode: "+1-441"),
    Country(name: "Bhutan", code: "BT", dialCode: "+975"),
    Country(name: "Bolivia", code: "BO", dialCode: "+591"),
    Country(
        name: "Bonaire, Sint Eustatius and Saba", code: "BQ", dialCode: "+599"),
    Country(name: "Bosnia and Herzegovina", code: "BA", dialCode: "+387"),
    Country(name: "Botswana", code: "BW", dialCode: "+267"),
    Country(name: "Bouvet Island", code: "BV", dialCode: "+47"),
    Country(name: "Brazil", code: "BR", dialCode: "+55"),
    Country(
        name: "British Indian Ocean Territory", code: "IO", dialCode: "+246"),
    Country(name: "Brunei Darussalam", code: "BN", dialCode: "+673"),
    Country(name: "Bulgaria", code: "BG", dialCode: "+359"),
    Country(name: "Burkina Faso", code: "BF", dialCode: "+226"),
    Country(name: "Burundi", code: "BI", dialCode: "+257"),
    Country(name: "Cabo Verde", code: "CV", dialCode: "+238"),
    Country(name: "Cambodia", code: "KH", dialCode: "+855"),
    Country(name: "Cameroon", code: "CM", dialCode: "+237"),
    Country(name: "Canada", code: "CA", dialCode: "+1"),
    Country(name: "Cayman Islands", code: "KY", dialCode: "+1-345"),
    Country(name: "Central African Republic", code: "CF", dialCode: "+236"),
    Country(name: "Chad", code: "TD", dialCode: "+235"),
    Country(name: "Chile", code: "CL", dialCode: "+56"),
    Country(name: "China", code: "CN", dialCode: "+86"),
    Country(name: "Christmas Island", code: "CX", dialCode: "+61"),
    Country(name: "Cocos (Keeling) Islands", code: "CC", dialCode: "+61"),
    Country(name: "Colombia", code: "CO", dialCode: "+57"),
    Country(name: "Comoros", code: "KM", dialCode: "+269"),
    Country(name: "Congo", code: "CG", dialCode: "+242"),
    Country(
        name: "Congo, Democratic Republic of the",
        code: "CD",
        dialCode: "+243"),
    Country(name: "Cook Islands", code: "CK", dialCode: "+682"),
    Country(name: "Costa Rica", code: "CR", dialCode: "+506"),
    Country(name: "Côte d'Ivoire", code: "CI", dialCode: "+225"),
    Country(name: "Croatia", code: "HR", dialCode: "+385"),
    Country(name: "Cuba", code: "CU", dialCode: "+53"),
    Country(name: "Curaçao", code: "CW", dialCode: "+599"),
    Country(name: "Cyprus", code: "CY", dialCode: "+357"),
    Country(name: "Czech Republic", code: "CZ", dialCode: "+420"),
    Country(name: "Denmark", code: "DK", dialCode: "+45"),
    Country(name: "Djibouti", code: "DJ", dialCode: "+253"),
    Country(name: "Dominica", code: "DM", dialCode: "+1-767"),
    Country(name: "Dominican Republic", code: "DO", dialCode: "+1-809"),
    Country(name: "Ecuador", code: "EC", dialCode: "+593"),
    Country(name: "Egypt", code: "EG", dialCode: "+20"),
    Country(name: "El Salvador", code: "SV", dialCode: "+503"),
    Country(name: "Equatorial Guinea", code: "GQ", dialCode: "+240"),
    Country(name: "Eritrea", code: "ER", dialCode: "+291"),
    Country(name: "Estonia", code: "EE", dialCode: "+372"),
    Country(name: "Eswatini", code: "SZ", dialCode: "+268"),
    Country(name: "Ethiopia", code: "ET", dialCode: "+251"),
    Country(name: "Falkland Islands (Malvinas)", code: "FK", dialCode: "+500"),
    Country(name: "Faroe Islands", code: "FO", dialCode: "+298"),
    Country(name: "Fiji", code: "FJ", dialCode: "+679"),
    Country(name: "Finland", code: "FI", dialCode: "+358"),
    Country(name: "France", code: "FR", dialCode: "+33"),
    Country(name: "French Guiana", code: "GF", dialCode: "+594"),
    Country(name: "French Polynesia", code: "PF", dialCode: "+689"),
    Country(name: "French Southern Territories", code: "TF", dialCode: "+262"),
    Country(name: "Gabon", code: "GA", dialCode: "+241"),
    Country(name: "Gambia", code: "GM", dialCode: "+220"),
    Country(name: "Georgia", code: "GE", dialCode: "+995"),
    Country(name: "Germany", code: "DE", dialCode: "+49"),
    Country(name: "Ghana", code: "GH", dialCode: "+233"),
    Country(name: "Gibraltar", code: "GI", dialCode: "+350"),
    Country(name: "Greece", code: "GR", dialCode: "+30"),
    Country(name: "Greenland", code: "GL", dialCode: "+299"),
    Country(name: "Grenada", code: "GD", dialCode: "+1-473"),
    Country(name: "Guadeloupe", code: "GP", dialCode: "+590"),
    Country(name: "Guam", code: "GU", dialCode: "+1-671"),
    Country(name: "Guatemala", code: "GT", dialCode: "+502"),
    Country(name: "Guernsey", code: "GG", dialCode: "+44-1481"),
    Country(name: "Guinea", code: "GN", dialCode: "+224"),
    Country(name: "Guinea-Bissau", code: "GW", dialCode: "+245"),
    Country(name: "Guyana", code: "GY", dialCode: "+592"),
    Country(name: "Haiti", code: "HT", dialCode: "+509"),
    Country(
        name: "Heard Island and McDonald Islands",
        code: "HM",
        dialCode: "+672"),
    Country(name: "Holy See (Vatican City State)", code: "VA", dialCode: "+39"),
    Country(name: "Honduras", code: "HN", dialCode: "+504"),
    Country(name: "Hong Kong", code: "HK", dialCode: "+852"),
    Country(name: "Hungary", code: "HU", dialCode: "+36"),
    Country(name: "Iceland", code: "IS", dialCode: "+354"),
    Country(name: "India", code: "IN", dialCode: "+91"),
    Country(name: "Indonesia", code: "ID", dialCode: "+62"),
    Country(name: "Iran, Islamic Republic of", code: "IR", dialCode: "+98"),
    Country(name: "Iraq", code: "IQ", dialCode: "+964"),
    Country(name: "Ireland", code: "IE", dialCode: "+353"),
    Country(name: "Isle of Man", code: "IM", dialCode: "+44-1624"),
    Country(name: "Israel", code: "IL", dialCode: "+972"),
    Country(name: "Italy", code: "IT", dialCode: "+39"),
    Country(name: "Jamaica", code: "JM", dialCode: "+1-876"),
    Country(name: "Japan", code: "JP", dialCode: "+81"),
    Country(name: "Jersey", code: "JE", dialCode: "+44-1534"),
    Country(name: "Jordan", code: "JO", dialCode: "+962"),
    Country(name: "Kazakhstan", code: "KZ", dialCode: "+7"),
    Country(name: "Kenya", code: "KE", dialCode: "+254"),
    Country(name: "Kiribati", code: "KI", dialCode: "+686"),
    Country(
        name: "Korea, Democratic People's Republic of",
        code: "KP",
        dialCode: "+850"),
    Country(name: "Korea, Republic of", code: "KR", dialCode: "+82"),
    Country(name: "Kuwait", code: "KW", dialCode: "+965"),
    Country(name: "Kyrgyzstan", code: "KG", dialCode: "+996"),
    Country(
        name: "Lao People's Democratic Republic", code: "LA", dialCode: "+856"),
    Country(name: "Latvia", code: "LV", dialCode: "+371"),
    Country(name: "Lebanon", code: "LB", dialCode: "+961"),
    Country(name: "Lesotho", code: "LS", dialCode: "+266"),
    Country(name: "Liberia", code: "LR", dialCode: "+231"),
    Country(name: "Libya", code: "LY", dialCode: "+218"),
    Country(name: "Liechtenstein", code: "LI", dialCode: "+423"),
    Country(name: "Lithuania", code: "LT", dialCode: "+370"),
    Country(name: "Luxembourg", code: "LU", dialCode: "+352"),
    Country(name: "Macao", code: "MO", dialCode: "+853"),
    Country(name: "Madagascar", code: "MG", dialCode: "+261"),
    Country(name: "Malawi", code: "MW", dialCode: "+265"),
    Country(name: "Malaysia", code: "MY", dialCode: "+60"),
    Country(name: "Maldives", code: "MV", dialCode: "+960"),
    Country(name: "Mali", code: "ML", dialCode: "+223"),
    Country(name: "Malta", code: "MT", dialCode: "+356"),
    Country(name: "Marshall Islands", code: "MH", dialCode: "+692"),
    Country(name: "Martinique", code: "MQ", dialCode: "+596"),
    Country(name: "Mauritania", code: "MR", dialCode: "+222"),
    Country(name: "Mauritius", code: "MU", dialCode: "+230"),
    Country(name: "Mayotte", code: "YT", dialCode: "+262"),
    Country(name: "Mexico", code: "MX", dialCode: "+52"),
    Country(
        name: "Micronesia, Federated States of", code: "FM", dialCode: "+691"),
    Country(name: "Moldova, Republic of", code: "MD", dialCode: "+373"),
    Country(name: "Monaco", code: "MC", dialCode: "+377"),
    Country(name: "Mongolia", code: "MN", dialCode: "+976"),
    Country(name: "Montenegro", code: "ME", dialCode: "+382"),
    Country(name: "Montserrat", code: "MS", dialCode: "+1-664"),
    Country(name: "Morocco", code: "MA", dialCode: "+212"),
    Country(name: "Mozambique", code: "MZ", dialCode: "+258"),
    Country(name: "Myanmar", code: "MM", dialCode: "+95"),
    Country(name: "Namibia", code: "NA", dialCode: "+264"),
    Country(name: "Nauru", code: "NR", dialCode: "+674"),
    Country(name: "Nepal", code: "NP", dialCode: "+977"),
    Country(name: "Netherlands", code: "NL", dialCode: "+31"),
    Country(name: "New Caledonia", code: "NC", dialCode: "+687"),
    Country(name: "New Zealand", code: "NZ", dialCode: "+64"),
    Country(name: "Nicaragua", code: "NI", dialCode: "+505"),
    Country(name: "Niger", code: "NE", dialCode: "+227"),
    Country(name: "Nigeria", code: "NG", dialCode: "+234"),
    Country(name: "Niue", code: "NU", dialCode: "+683"),
    Country(name: "Norfolk Island", code: "NF", dialCode: "+672"),
    Country(name: "North Macedonia", code: "MK", dialCode: "+389"),
    Country(name: "Northern Mariana Islands", code: "MP", dialCode: "+1-670"),
    Country(name: "Norway", code: "NO", dialCode: "+47"),
    Country(name: "Oman", code: "OM", dialCode: "+968"),
    Country(name: "Pakistan", code: "PK", dialCode: "+92"),
    Country(name: "Palau", code: "PW", dialCode: "+680"),
    Country(name: "Palestine, State of", code: "PS", dialCode: "+970"),
    Country(name: "Panama", code: "PA", dialCode: "+507"),
    Country(name: "Papua New Guinea", code: "PG", dialCode: "+675"),
    Country(name: "Paraguay", code: "PY", dialCode: "+595"),
    Country(name: "Peru", code: "PE", dialCode: "+51"),
    Country(name: "Philippines", code: "PH", dialCode: "+63"),
    Country(name: "Pitcairn", code: "PN", dialCode: "+64"),
    Country(name: "Poland", code: "PL", dialCode: "+48"),
    Country(name: "Portugal", code: "PT", dialCode: "+351"),
    Country(name: "Puerto Rico", code: "PR", dialCode: "+1-787"),
    Country(name: "Qatar", code: "QA", dialCode: "+974"),
    Country(name: "Réunion", code: "RE", dialCode: "+262"),
    Country(name: "Romania", code: "RO", dialCode: "+40"),
    Country(name: "Russian Federation", code: "RU", dialCode: "+7"),
    Country(name: "Rwanda", code: "RW", dialCode: "+250"),
    Country(name: "Saint Barthélemy", code: "BL", dialCode: "+590"),
    Country(
        name: "Saint Helena, Ascension and Tristan da Cunha",
        code: "SH",
        dialCode: "+290"),
    Country(name: "Saint Kitts and Nevis", code: "KN", dialCode: "+1-869"),
    Country(name: "Saint Lucia", code: "LC", dialCode: "+1-758"),
    Country(name: "Saint Martin (French part)", code: "MF", dialCode: "+590"),
    Country(name: "Saint Pierre and Miquelon", code: "PM", dialCode: "+508"),
    Country(
        name: "Saint Vincent and the Grenadines",
        code: "VC",
        dialCode: "+1-784"),
    Country(name: "Samoa", code: "WS", dialCode: "+685"),
    Country(name: "San Marino", code: "SM", dialCode: "+378"),
    Country(name: "Sao Tome and Principe", code: "ST", dialCode: "+239"),
    Country(name: "Saudi Arabia", code: "SA", dialCode: "+966"),
    Country(name: "Senegal", code: "SN", dialCode: "+221"),
    Country(name: "Serbia", code: "RS", dialCode: "+381"),
    Country(name: "Seychelles", code: "SC", dialCode: "+248"),
    Country(name: "Sierra Leone", code: "SL", dialCode: "+232"),
    Country(name: "Singapore", code: "SG", dialCode: "+65"),
    Country(name: "Sint Maarten (Dutch part)", code: "SX", dialCode: "+1-721"),
    Country(name: "Slovakia", code: "SK", dialCode: "+421"),
    Country(name: "Slovenia", code: "SI", dialCode: "+386"),
    Country(name: "Solomon Islands", code: "SB", dialCode: "+677"),
    Country(name: "Somalia", code: "SO", dialCode: "+252"),
    Country(name: "South Africa", code: "ZA", dialCode: "+27"),
    Country(
        name: "South Georgia and the South Sandwich Islands",
        code: "GS",
        dialCode: "+500"),
    Country(name: "South Sudan", code: "SS", dialCode: "+211"),
    Country(name: "Spain", code: "ES", dialCode: "+34"),
    Country(name: "Sri Lanka", code: "LK", dialCode: "+94"),
    Country(name: "Sudan", code: "SD", dialCode: "+249"),
    Country(name: "Suriname", code: "SR", dialCode: "+597"),
    Country(name: "Svalbard and Jan Mayen", code: "SJ", dialCode: "+47"),
    Country(name: "Sweden", code: "SE", dialCode: "+46"),
    Country(name: "Switzerland", code: "CH", dialCode: "+41"),
    Country(name: "Syrian Arab Republic", code: "SY", dialCode: "+963"),
    Country(name: "Taiwan, Province of China", code: "TW", dialCode: "+886"),
    Country(name: "Tajikistan", code: "TJ", dialCode: "+992"),
    Country(name: "Tanzania, United Republic of", code: "TZ", dialCode: "+255"),
    Country(name: "Thailand", code: "TH", dialCode: "+66"),
    Country(name: "Timor-Leste", code: "TL", dialCode: "+670"),
    Country(name: "Togo", code: "TG", dialCode: "+228"),
    Country(name: "Tokelau", code: "TK", dialCode: "+690"),
    Country(name: "Tonga", code: "TO", dialCode: "+676"),
    Country(name: "Trinidad and Tobago", code: "TT", dialCode: "+1-868"),
    Country(name: "Tunisia", code: "TN", dialCode: "+216"),
    Country(name: "Turkey", code: "TR", dialCode: "+90"),
    Country(name: "Turkmenistan", code: "TM", dialCode: "+993"),
    Country(name: "Turks and Caicos Islands", code: "TC", dialCode: "+1-649"),
    Country(name: "Tuvalu", code: "TV", dialCode: "+688"),
    Country(name: "Uganda", code: "UG", dialCode: "+256"),
    Country(name: "Ukraine", code: "UA", dialCode: "+380"),
    Country(name: "United Arab Emirates", code: "AE", dialCode: "+971"),
    Country(name: "United Kingdom", code: "GB", dialCode: "+44"),
    Country(name: "United States", code: "US", dialCode: "+1"),
    Country(
        name: "United States Minor Outlying Islands",
        code: "UM",
        dialCode: "+1"),
    Country(name: "Uruguay", code: "UY", dialCode: "+598"),
    Country(name: "Uzbekistan", code: "UZ", dialCode: "+998"),
    Country(name: "Vanuatu", code: "VU", dialCode: "+678"),
    Country(
        name: "Venezuela, Bolivarian Republic of", code: "VE", dialCode: "+58"),
    Country(name: "Viet Nam", code: "VN", dialCode: "+84"),
    Country(name: "Virgin Islands, British", code: "VG", dialCode: "+1-284"),
    Country(name: "Virgin Islands, U.S.", code: "VI", dialCode: "+1-340"),
    Country(name: "Wallis and Futuna", code: "WF", dialCode: "+681"),
    Country(name: "Western Sahara", code: "EH", dialCode: "+212"),
    Country(name: "Yemen", code: "YE", dialCode: "+967"),
    Country(name: "Zambia", code: "ZM", dialCode: "+260"),
    Country(name: "Zimbabwe", code: "ZW", dialCode: "+263"),
  ];
}

// Define a Country model
class Country {
  final String name;
  final String code; // ISO 3166-1 alpha-2 code
  final String dialCode;

  Country({
    required this.name,
    required this.code,
    required this.dialCode,
  });
}

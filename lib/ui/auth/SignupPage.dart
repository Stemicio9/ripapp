
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/entity/CityEntity.dart';
import 'package:ripapp/entity/UserEntity.dart';
import 'package:ripapp/ui/auth/ChooseCitiesPage.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/EmptyAppBar.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  FocusNode emailNode = new FocusNode();
  FocusNode passNode = new FocusNode();
  FocusNode nameNode = new FocusNode();
  FocusNode lastNameNode = new FocusNode();
  FocusNode phoneNode = new FocusNode();
  TextEditingController emailController = new TextEditingController();
  TextEditingController passwordController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController lastnameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

  bool obscurePass = true;

  List<String> prefixes = ["+1","+7","+7","+20","+27","+30","+31","+32","+33","+34","+36","+39","+40","+41","+43","+44","+45","+46","+47","+48","+49","+51","+52","+53","+53","+54","+55","+56","+57","+58","+60","+61","+61","+62","+63","+64","+65","+66","+81","+82","+84","+86","+90","+91","+92","+93","+94","+95","+98","+212","+213","+216","+218","+220","+221","+222","+223","+224","+225","+226","+227","+229","+230","+231","+232","+233","+234","+235","+236","+237","+238","+239","+240","+241","+242","+243","+244","+245","+248","+249","+250","+251","+252","+253","+254","+255","+256","+257","+258","+260","+261","+262","+263","+264","+265","+266","+267","+268","+269","+269","+290","+291","+297","+298","+299","+350","+351","+352","+353","+354","+355","+356","+357","+358","+359","+370","+371","+372","+373","+374","+375","+376","+377","+378","+380","+385","+386","+387","+389","+418","+420","+421","+423","+500","+501","+502","+503","+504","+505","+506","+507","+508","+509","+590","+591","+592","+593","+594","+595","+596","+597","+598","+599","+670","+672","+672","+673","+674","+675","+676","+677","+678","+679","+680","+681","+682","+683","+685","+686","+687","+688","+689","+690","+691","+692","+850","+852","+853","+855","+856","+880","+886","+960","+961","+962","+963","+964","+965","+966","+967","+968","+970","+971","+972","+973","+974","+975","+976","+977","+992","+993","+994","+995","+996","+998"];
  String _prefix;
  String DEFAULT_PREFIX = "+39";

  List<CityEntity> selectedCities = [];

  bool termsAndCond = false;
  bool privacyPolicy = false;
  bool notifications = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return
      Scaffold(
        appBar: EmptyAppBar(),
        body:
        SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 20,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(icon: Icon(Icons.arrow_back_ios, size: 25, color: AppTheme.almostBlack,), onPressed: () async {
                    Navigator.of(context).pop();
                  }),
                ),
                Center(
                    child: Image.asset("assets/logo_rect_transparent.png", width: width * 0.8, fit: BoxFit.cover)
                ),
                SizedBox(height: height * 0.02),
                Text(
                  MyLocalizations.of(context, "signup").toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.baseColor,
                    fontStyle:  FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    fontSize: 25.0,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 50,
                      width: width/2.5,
                      child: TextField(
                        controller: nameController,
                        focusNode: nameNode,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        maxLines: 1,
                        style: TextStyle(
                            color: AppTheme.almostBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                        decoration: InputDecoration(
                          //border: OutlineInputBorder(),
                          border: InputBorder.none,
                          hintText: MyLocalizations.of(context, "name"),
                          hintStyle: TextStyle(
                              color: AppTheme.almostBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                        onEditingComplete: () => lastNameNode.requestFocus(),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: width/2.5,
                      child: TextField(
                        controller: lastnameController,
                        focusNode: lastNameNode,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        maxLines: 1,
                        style: TextStyle(
                            color: AppTheme.almostBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0),
                        decoration: InputDecoration(
                          //border: OutlineInputBorder(),
                          border: InputBorder.none,
                          hintText: MyLocalizations.of(context, "lastname"),
                          hintStyle: TextStyle(
                              color: AppTheme.almostBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0),
                        ),
                        onEditingComplete: () => emailNode.requestFocus(),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: width/2.5,
                      height: 10,
                      child: Divider(
                        thickness: 0.5,
                        color: AppTheme.almostBlack,
                      ),
                    ),
                    Container(
                      width: width/2.5,
                      height: 10,
                      child: Divider(
                        thickness: 0.5,
                        color: AppTheme.almostBlack,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0),
                TextField(
                  controller: emailController,
                  focusNode: emailNode,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                  style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                  decoration: InputDecoration(
                    //border: OutlineInputBorder(),
                    border: InputBorder.none,
                    hintText: MyLocalizations.of(context, "email"),
                    hintStyle: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                  ),
                  onEditingComplete: () => passNode.requestFocus(),
                ),
                Divider(
                  thickness: 0.5,
                  color: AppTheme.almostBlack,
                ),
                TextField(
                  controller: passwordController,
                  focusNode: passNode,
                  obscureText: obscurePass,
                  keyboardType: TextInputType.visiblePassword,
                  textInputAction: TextInputAction.next,
                  maxLines: 1,
                  style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0),
                  decoration: InputDecoration(
                    //border: OutlineInputBorder(),
                      border: InputBorder.none,
                      hintText: MyLocalizations.of(context, "password"),
                      hintStyle: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                      suffixIcon: InkWell(
                        onTap: () {
                          setState(() {
                            obscurePass = !obscurePass;
                          });
                        },
                        child: Icon(
                          Icons.remove_red_eye, color: AppTheme.almostBlack, size: 20,
                        ),
                      )
                  ),
                  onEditingComplete: () => phoneNode.requestFocus(),
                ),
                Divider(
                  thickness: 0.5,
                  color: AppTheme.almostBlack,
                ),

                Row(
                  children: <Widget>[
                    /*Icon(
                      Icons.phone,
                      color: Themee.TheTableTheme.baseColor,
                      size: 20,
                    ),
                    SizedBox(width: 15,),*/
                    Container(
                      width: 75,
                      color: Colors.transparent,
                      child: Theme(
                        data: new ThemeData(
                            canvasColor: Colors.white,
                            primaryColor: Colors.white,
                            accentColor: Colors.white,
                            hintColor: Colors.white),
                        child: DropdownButton<String>(
                          elevation: 24,
                          isExpanded: true,
                          underline: SizedBox(),
                          itemHeight: 50,
                          items:
                          prefixes
                              .map((mapEntry)=> DropdownMenuItem<String>(
                            value: mapEntry,
                            child: Text(
                              mapEntry,
                              style: TextStyle(
                                  color: AppTheme.almostBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18
                              ),
                            ),
                          )
                          ).toList(),
                          value: _prefix != null ? _prefix : DEFAULT_PREFIX,
                          onChanged: (value) {
                            setState(() {
                              _prefix = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 15,),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        focusNode: phoneNode,
                        keyboardType: TextInputType.number,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (text) => Utils.unfocusTextField(context),
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.almostBlack),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          /*suffixIcon: InkWell(
                            onTap: () {
                              Utils.showSimplePopupMessage(context,
                                  MyLocalizations.of(context, "phone_box_title"),
                                  MyLocalizations.of(context, "phone_box_dscr")
                              );
                            },
                            child: Icon(
                                Icons.info_outline,
                                size: 24.0,
                                color: Themee.TheTableTheme.baseColor
                            ),
                          ),*/
                          contentPadding: EdgeInsets.only(top: .0),
                          hintText: MyLocalizations.of(context, "phone"),
                          hintStyle: TextStyle(
                              fontSize: 18.0,
                              color: AppTheme.almostBlack,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Divider(
                  thickness: 0.5,
                  color: AppTheme.almostBlack,
                ),
                InkWell(
                      onTap: () {
                        showSelectCitiesPopup();
                      },
                      child: Container(
                        height: 50,
                        width: width,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            MyLocalizations.of(context, "cities_of_interest") +
                                (selectedCities.isNotEmpty ?
                                  ": " + selectedCities.length.toString() + " " + MyLocalizations.of(context, "selected")
                                 : ""),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: AppTheme.almostBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                Divider(
                  thickness: 0.5,
                  color: AppTheme.almostBlack,
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: selectedCities.map((city) => InkWell(
                            onTap: () {
                              setState(() {
                                selectedCities.remove(city);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.baseColor,
                                borderRadius: BorderRadius.circular(40)
                              ),
                              margin: EdgeInsets.only(right: 10),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    city.name,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  SizedBox(width: 10,),
                                  Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Icon(Icons.clear, size: 30, color: Colors.white,),
                                  ),

                                ],
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: selectedCities.isNotEmpty ? 20 : 0),
                //acceptance
                Row(
                  children: [
                    Checkbox(
                      shape: CircleBorder(),
                      checkColor: Colors.white,
                      activeColor: AppTheme.almostBlack,
                      value: termsAndCond,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      onChanged: (bool val) {
                        setState(() {
                          termsAndCond = val;
                        });
                      },
                    ),
                    Text(
                      MyLocalizations.of(context, "accept_terms_cond"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    IconButton(icon: Icon(Icons.info_outline, size: 25, color: AppTheme.almostBlack,), onPressed: () async {
                      String link = await Utils.getAppLink("terms_and_conditions");
                      if (await canLaunch(link))
                        await launch(link);
                    })
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      shape: CircleBorder(),
                        checkColor: Colors.white,
                        activeColor: AppTheme.almostBlack,
                        value: privacyPolicy,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        onChanged: (bool val) {
                          setState(() {
                            privacyPolicy = val;
                          });
                        }
                    ),
                    Text(
                      MyLocalizations.of(context, "accept_privacy"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    IconButton(icon: Icon(Icons.info_outline, size: 25, color: AppTheme.almostBlack,), onPressed: () async {
                      String link = await Utils.getAppLink("privacy_policy");
                      if (await canLaunch(link))
                        await launch(link);
                      /*Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Scaffold(
                            appBar: AppBar(
                              elevation: 0,
                              backgroundColor: Colors.white,
                              actionsIconTheme: IconThemeData(color: Colors.black),
                              iconTheme: IconThemeData(color: Colors.black),
                            ),
                            body: PDF().cachedFromUrl(
                              Configuration.PRIVACY,
                              placeholder: (progress) => Center(child: Text('$progress %')),
                              errorWidget: (error) => Center(child: Text(error.toString())),
                            ),
                          ))
                      );*/
                    })
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                      shape: CircleBorder(),
                        checkColor: Colors.white,
                        activeColor: AppTheme.almostBlack,
                        value: notifications,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        onChanged: (bool val) {
                          setState(() {
                            notifications = val;
                          });
                        }
                    ),
                    Text(
                      MyLocalizations.of(context, "enable_notifications"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontSize: 18.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    IconButton(icon: Icon(Icons.info_outline, size: 25, color: AppTheme.almostBlack,), onPressed: () async {
                      Utils.showSimplePopupMessage(
                          context,
                          MyLocalizations.of(context, "notifications_info_title"),
                          MyLocalizations.of(context, "notifications_info_dscr"));
                    })
                  ],
                ),
                SizedBox(height:20),
                Row(
                  children: [
                    Expanded(
                      child: RoundedButton(MyLocalizations.of(context, "signup"), Colors.white, AppTheme.baseColor, () {
                        signup();
                      }),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.05),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      MyLocalizations.of(context, "already_have_account"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                        fontSize: 18.0,
                      ),
                    ),
                    SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Text(
                        MyLocalizations.of(context, "login"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppTheme.baseColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.05),
              ],
            ),
          ),
        ),
      );
  }

  void signup() async {
    if(nameController.text.isEmpty || lastnameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty ||
        phoneController.text.isEmpty) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "please_fill_all_fields"), context: context);
      return;
    }
    if(passwordController.text.length < 8 /*||
        !passwordController.text.contains(new RegExp(r'[A-Z]')) ||
        !passwordController.text.contains(new RegExp(r'[-!$%^&*()_+|~=`{}\[\]:";<>?,.\/]'))*/
    ){
      Utils.showErrorSnackBar(MyLocalizations.of(context, "password_too_short"), context: context);
      return;
    }
    if(!passwordController.text.contains(new RegExp(r'[0-9]'))
    ){
      Utils.showErrorSnackBar(MyLocalizations.of(context, "password_must_contain_numbers"), context: context);
      return;
    }
    if(selectedCities.isEmpty) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "please_choose_city"), context: context);
      return;
    }
    Utils.showCustomHud(context);
    Tuple2<bool, String> res = await UserHandler().signUpWithEmailPassword(nameController.text, emailController.text, passwordController.text, context);
    print("RISPOSTA");
    print(res.item1);
    print(res.item2);
    if(res == null || res.item1 == null) {
      Utils.hideCustomHud(context);
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
      return;
    }
    if(!res.item1) {
      Utils.hideCustomHud(context);
      if((res.item2 != null))
        Utils.showErrorSnackBar(res.item2);
      else
        Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
      return;
    }
    User user = await UserHandler().getFirebaseUser();

    var token = await user.getIdToken();
    print("ID TOKEN = " + token);
    String idToken = await user.getIdToken();
    UserEntity userEntity = new UserEntity(
      name: nameController.text,
      surname: lastnameController.text,
      cities: selectedCities,
      email: emailController.text,
      phone: phoneController.text,
      prefix: _prefix ?? DEFAULT_PREFIX,
      notif: notifications,
      idtoken: idToken
    );
     bool success = await UserHandler().createUser(userEntity);

 //   bool success = await UserHandler().createAdmin(userEntity);
    if(!success) {
      Utils.hideCustomHud(context);
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
      await user.delete();
      return;
    }
    success = await UserHandler().login(user, context);
    Utils.hideCustomHud(context);
    if(success) {
      Navigator.of(context).popUntil(ModalRoute.withName('/'));
      Navigator.of(context).pushNamed(
          "/user_registered"
      );

    }
    else
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
  }

  void showSelectCitiesPopup() async {
    final selectedValues = await Get.to(ChooseCitiesPage(selectedCities));
    /*final selectedValues = await showDialog<List<CityEntity>>(
      context: context,
      builder: (BuildContext context) {
        return MultiSelectDialog(
          title: MyLocalizations.of(context, "cities_of_interest"),
          items: cities.map((city) => MultiSelectDialogItem(city, city.name)).toList(),
          initialSelectedValues: selectedCities.toSet(),
        );
      },
    );*/
    if(this.mounted && selectedValues != null)
      setState(() {
        selectedCities = selectedValues;
      });
  }

}





import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ripapp/SplashScreen.dart';
import 'package:ripapp/business_logic/UserHandler.dart';
import 'package:ripapp/entity/UserEntity.dart';
import 'package:ripapp/ui/auth/ChangePasswordPage.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/ui/common/RoundedButton.dart';
import 'package:ripapp/utils/Configuration.dart';
import 'package:ripapp/utils/MyLocalizations.dart';
import 'package:ripapp/utils/Utils.dart';

class AdminProfilePage extends StatefulWidget {
  @override
  _AdminProfilePageState createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {

  UserEntity userEntity;
  bool editMode = false;
  User user;

  FocusNode emailNode = new FocusNode();
  FocusNode passNode = new FocusNode();
  FocusNode confNode = new FocusNode();
  FocusNode nameNode = new FocusNode();
  FocusNode lastNameNode = new FocusNode();
  FocusNode phoneNode = new FocusNode();
  TextEditingController emailController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();
  TextEditingController lastnameController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();

  List<String> prefixes = ["+1","+7","+7","+20","+27","+30","+31","+32","+33","+34","+36","+39","+40","+41","+43","+44","+45","+46","+47","+48","+49","+51","+52","+53","+53","+54","+55","+56","+57","+58","+60","+61","+61","+62","+63","+64","+65","+66","+81","+82","+84","+86","+90","+91","+92","+93","+94","+95","+98","+212","+213","+216","+218","+220","+221","+222","+223","+224","+225","+226","+227","+229","+230","+231","+232","+233","+234","+235","+236","+237","+238","+239","+240","+241","+242","+243","+244","+245","+248","+249","+250","+251","+252","+253","+254","+255","+256","+257","+258","+260","+261","+262","+263","+264","+265","+266","+267","+268","+269","+269","+290","+291","+297","+298","+299","+350","+351","+352","+353","+354","+355","+356","+357","+358","+359","+370","+371","+372","+373","+374","+375","+376","+377","+378","+380","+385","+386","+387","+389","+418","+420","+421","+423","+500","+501","+502","+503","+504","+505","+506","+507","+508","+509","+590","+591","+592","+593","+594","+595","+596","+597","+598","+599","+670","+672","+672","+673","+674","+675","+676","+677","+678","+679","+680","+681","+682","+683","+685","+686","+687","+688","+689","+690","+691","+692","+850","+852","+853","+855","+856","+880","+886","+960","+961","+962","+963","+964","+965","+966","+967","+968","+970","+971","+972","+973","+974","+975","+976","+977","+992","+993","+994","+995","+996","+998"];
  String _prefix;
  String DEFAULT_PREFIX = "+39";

  File imageFile;

  @override
  void initState() {
    super.initState();

    UserHandler().getFirebaseUser().then((u) {
      if(u != null)
        UserHandler().getUser().then((value) {
          if(this.mounted && value != null) {
            userEntity = value;
            user = u;
            _resetValues();
            setState(() {

            });
          }
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return userEntity  == null ? Utils.getProgressIndicator() :
    Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    editMode ? InkWell(
                      onTap: () {
                        setState(() {
                          editMode = false;
                          _resetValues();
                        });
                      },
                      child: Text(
                        MyLocalizations.of(context, "cancel"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ) :SizedBox(width: 25),
                    InkWell(
                      onTap: editMode ? ()  async {
                        File photo = await Utils.pickImageFromGallery(context);
                        if(this.mounted)
                          setState(() {
                            imageFile = photo;
                          });
                      } : null,
                      child: Container(
                        width: width * 0.5,
                        height: width * 0.5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: AppTheme.almostBlack, width: 2),
                          image: imageFile != null || userEntity.photourl != null ?
                          DecorationImage(
                            image:
                            imageFile != null ?
                            FileImage(imageFile)
                                :
                            CachedNetworkImageProvider(userEntity.photourl,),
                            fit: BoxFit.cover,
                          )
                              : null,
                        ),
                        child: imageFile == null && userEntity.photourl == null ?
                        Center(
                          child: Text(
                            editMode ? MyLocalizations.of(context, "tap_insert_photo") : MyLocalizations.of(context, "no_photo"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.almostBlack,
                              fontWeight: FontWeight.normal,
                              fontSize: 18.0,
                            ),
                          ),
                        ) : SizedBox(),
                      ),
                    ),
                    !editMode ?
                    InkWell(
                        onTap: () {
                          setState(() {
                            editMode = true;
                          });
                        },
                        child: Image.asset("assets/edit_icon.png", width: 25, fit: BoxFit.cover)
                    ) :
                    InkWell(
                      onTap: () async {
                        bool res = await applyModifications();
                        if(!res)
                          return;
                        setState(() {
                          editMode = false;
                        });
                      },
                      child: Text(
                        MyLocalizations.of(context, "apply"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: AppTheme.almostBlack,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    )

                  ],
                ),
                SizedBox(height: editMode ? 5 : 0),
                /*editMode ?
              Center(
                child: InkWell(
                  onTap: () async {
                    File photo = await Utils.pickImageFromGallery(context);
                    if(this.mounted)
                      setState(() {
                        imageFile = photo;
                      });
                  },
                  child: Text(
                    MyLocalizations.of(context, "tap_insert_photo"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.almostBlack,
                      fontWeight: FontWeight.normal,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ) : SizedBox(),*/
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    MyLocalizations.of(context, "my_profile"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppTheme.baseColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                    ),
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
                        enabled: editMode,
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
                        enabled: editMode,
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
                  enabled: editMode,
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
                editMode ? Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: () {
                      Get.to(ChangePasswordPage());
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        MyLocalizations.of(context, "change_password"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: AppTheme.almostBlack,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0
                        ),
                      ),
                    ),
                  ),
                ) : SizedBox(),
                editMode ? Divider(
                  thickness: 0.5,
                  color: AppTheme.almostBlack,
                ) : SizedBox(),
                /*         !editMode ?  Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    MyLocalizations.of(context, "new_password"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                    ),
                  ),
                ),
              ) :
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
                    hintText: MyLocalizations.of(context, "new_password"),
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
                onEditingComplete: () => confNode.requestFocus(),
              ),
              Divider(
                thickness: 0.5,
                color: AppTheme.almostBlack,
              ),
              !editMode ?  Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    MyLocalizations.of(context, "confirm_password"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                    ),
                  ),
                ),
              ) :
              TextField(
                controller: passwordConfirmationController,
                focusNode: confNode,
                obscureText: obscurePassConf,
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
                    hintText: MyLocalizations.of(context, "confirm_password"),
                    hintStyle: TextStyle(
                        color: AppTheme.almostBlack,
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0),
                    suffixIcon: InkWell(
                      onTap: () {
                        setState(() {
                          obscurePassConf = !obscurePassConf;
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
*/
                Row(
                  children: <Widget>[
                    editMode ?
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
                    )
                        :
                    Text(
                      userEntity.prefix,
                      style: TextStyle(
                        color: AppTheme.almostBlack,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 15,),
                    Expanded(
                      child: TextField(
                        enabled: editMode,
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
                Row(
                  children: [
                    Checkbox(
                        shape: CircleBorder(),
                        checkColor: Colors.white,
                        activeColor: AppTheme.almostBlack,
                        value: userEntity.notif,
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        onChanged: (bool val) async {
                          userEntity.notif = val;
                          Utils.showCustomHud(context);
                          bool success = await UserHandler().updateUser(userEntity);
                          Utils.hideCustomHud(context);
                          if (!success) {
                            Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
                            return;
                          }
                          else {
                            if (this.mounted)
                              setState(() {

                              });
                            Utils.showOkSnackBar(MyLocalizations.of(context, "user_updated"), context: context);
                          }
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
                SizedBox(height: 20),
                Container(
                  width: width,
                  child: RoundedButton(MyLocalizations.of(context, "delete_account"), Colors.white, Colors.red,
                          () async {
                        bool proceed = await Utils.showYesNoDialog(context, MyLocalizations.of(context, "are_you_sure"), MyLocalizations.of(context, "are_you_sure_go_back"));
                        if(!proceed)
                          return;
                        bool success = await UserHandler().deleteUser();
                        if(!success) {
                          Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
                          return;
                        }
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) => SplashScreen()), (r) => false);
                        Utils.showErrorSnackBar(MyLocalizations.of(context, "account_deleted"), context: context);
                      }),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        )
    );
  }



  void _resetValues() {
    imageFile = null;
    if(userEntity != null) {
      emailController.text = userEntity.email;
      nameController.text = userEntity.name;
      lastnameController.text = userEntity.surname;
      phoneController.text = userEntity.phone;
      _prefix = userEntity.prefix;
      if(this.mounted)
        setState(() {

        });
    }

  }

  Future<bool> applyModifications() async {
    if(nameController.text.isEmpty || lastnameController.text.isEmpty || emailController.text.isEmpty  ||
        phoneController.text.isEmpty) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "please_fill_all_fields"), context: context);
      return false;
    }

    /*if(selectedCities.isEmpty) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "please_choose_city"));
      return false;
    }*/
    Utils.showCustomHud(context);
    User user = await UserHandler().getFirebaseUser();
    if(emailController.text != userEntity.email) {
      await user.updateEmail(emailController.text);
      userEntity.email = emailController.text;
    }
    userEntity.name = nameController.text;
    userEntity.surname = lastnameController.text;
    userEntity.phone = phoneController.text;
    userEntity.prefix = _prefix;

    String photoUrl;
    if(imageFile != null) {
      photoUrl = await Utils.savePhotoToFirebase(Configuration.PROFILE_PHOTOS, userEntity.accountid, imageFile);
    }
    if(photoUrl != null)
      userEntity.photourl = photoUrl;

    bool success = await UserHandler().updateUser(userEntity);
    Utils.hideCustomHud(context);
    if(!success) {
      Utils.showErrorSnackBar(MyLocalizations.of(context, "something_went_wrong"), context: context);
      return false;
    }
    else {
      if(this.mounted)
        setState(() {

        });
      Utils.showOkSnackBar(MyLocalizations.of(context, "user_updated"), context: context);
      return true;
    }
  }


}
import 'package:flutter/material.dart';
import 'package:ripapp/utils/DelayedSearch.dart';
import 'package:ripapp/utils/Utils.dart';

typedef Widget ItemWidget(item);
typedef String OnChosen(value);

class AutocompleteTextField extends StatefulWidget {
  final String foundLabel;
  final String notFoundLabel;
  final Color foundLabelColor;
  final Color searchLabelColor;
  final String searchHint;
  final Color searchHintColor;
  final OnChosen onChosen;
  final Function search;
  final ItemWidget itemWidget;
  final FocusNode labelFocusNode;
  final Widget notFoundAdditionalWidget;
  final String initialValue;

  AutocompleteTextField(this.foundLabel, this.notFoundLabel, this.foundLabelColor, this.searchLabelColor, this.searchHint, this.searchHintColor,
      this.onChosen, this.search, this.itemWidget, {this.labelFocusNode, this.notFoundAdditionalWidget, this.initialValue});

  @override
  _AutocompleteTextFieldState createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  TextEditingController searchController = new TextEditingController();
  DelayedSearch delayedSearch;
  List<dynamic> results;

  @override
  void initState() {
    super.initState();
    Function onEmptyQuery = () => setState(() {
      searchController.text = "";
      results = [];
    });
    Function onComplete = (result) {
      if (this.mounted && result != null) {
        setState(() {
          results = result;
        });
      }
    };
    delayedSearch = new DelayedSearch(widget.search, 350, onEmptyQuery, onComplete);
    if(widget.initialValue != null) {
      searchController.text = widget.initialValue;
      searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: width - 100,
              child: TextField(
                focusNode: widget.labelFocusNode,
                controller: searchController,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (text) => Utils.unfocusTextField(context),
                style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: widget.searchLabelColor),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(top: .0),
                  hintText: widget.searchHint,
                  hintStyle: TextStyle(
                      fontSize: 18.0,
                      color: widget.searchHintColor,
                      fontWeight: FontWeight.normal
                  ),
                ),
                onChanged: (val) {
                  if(val.length < 2)
                    return;
                  delayedSearch.doSearchAddress(val);
                },
              ),
            ),
            searchController.text.isNotEmpty && results != null ?
              IconButton(icon: Icon(Icons.clear), onPressed: () {
                setState(() {
                  searchController.text = "";
                  results = null;
                });
              })
                :
              SizedBox()
          ],
        ),
        SizedBox(height: 10),
        Divider(
          thickness: 0.5,
          height: 1,
          color: widget.foundLabelColor,
        ),
        searchController.text.length > 2 ?
        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              results != null && results.isNotEmpty ?
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10,),
                    Text(
                      widget.foundLabel,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: widget.foundLabelColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    SizedBox(height: 20,),
                    Divider(
                      thickness: 0.5,
                      height: 1,
                      color: widget.foundLabelColor,
                    ),
                  ],
                ),
              )
                  :
              results != null ? Align(
                alignment: Alignment.centerLeft,
                child: Text(
                 widget.notFoundLabel,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: widget.searchLabelColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 16.0,
                  ),
                ),
              ) : SizedBox(),

            ],
          ),
        )
            :
        SizedBox(),
        results != null && results.isNotEmpty ?
        Container(
          padding: EdgeInsets.symmetric(horizontal: 0),
          child: SingleChildScrollView(
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: results.map((e) => InkWell(
                    onTap: () {
                      String label = widget.onChosen(e);
                      setState(() {
                        searchController.text = label;
                        results = null;
                      });
                    },
                    child: widget.itemWidget(e)
                )
                ).toList()
            ),
          ),
        ) : SizedBox(),
        results != null && widget.notFoundAdditionalWidget != null ?
        Align(
            alignment: Alignment.centerLeft,
            child: widget.notFoundAdditionalWidget
        )
            :
        SizedBox()
      ],
    );
  }

}

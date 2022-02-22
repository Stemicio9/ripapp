import 'package:flutter/material.dart';
import 'package:ripapp/ui/common/AppTheme.dart';
import 'package:ripapp/utils/MyLocalizations.dart';

class MultiSelectDialogItem<V> {
  const MultiSelectDialogItem(this.value, this.label);

  final V value;
  final String label;
}

class MultiSelectDialog<V> extends StatefulWidget {
  String title;

  MultiSelectDialog({Key key, this.title, this.items, this.initialSelectedValues}) : super(key: key);

  final List<MultiSelectDialogItem<V>> items;
  final Set<V> initialSelectedValues;

  @override
  State<StatefulWidget> createState() => _MultiSelectDialogState<V>();
}

class _MultiSelectDialogState<V> extends State<MultiSelectDialog<V>> {
  final _selectedValues = Set<V>();

  void initState() {
    super.initState();
    if (widget.initialSelectedValues != null) {
      _selectedValues.addAll(widget.initialSelectedValues);
    }
  }

  void _onItemCheckedChange(V itemValue, bool checked) {
    setState(() {
      if (checked) {
        _selectedValues.add(itemValue);
      } else {
        _selectedValues.remove(itemValue);
      }
    });
  }

  void _onCancelTap() {
    Navigator.pop(context);
  }

  void _onSubmitTap() {
    Navigator.pop(context, _selectedValues.toList());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        textAlign: TextAlign.left,
        style: TextStyle(
          color: AppTheme.baseColor,
          fontWeight: FontWeight.bold,
          fontSize: 22.0,
        ),
      ),
      contentPadding: EdgeInsets.only(top: 20.0),
      content: SingleChildScrollView(
        child: ListTileTheme(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          child: ListBody(
            children: widget.items.map(_buildItem).toList(),
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text(MyLocalizations.of(context, "cancel"),
            style: TextStyle(
                color: AppTheme.almostBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16
            ),
          ),
          onPressed: _onCancelTap,
        ),
        FlatButton(
          child: Text('Ok',
            style: TextStyle(
              color: AppTheme.almostBlack,
                fontWeight: FontWeight.bold,
                fontSize: 16
            ),
          ),
          onPressed: _onSubmitTap,
        )
      ],
    );
  }

  Widget _buildItem(MultiSelectDialogItem<V> item) {
    final checked = _selectedValues.contains(item.value);
    return
      InkWell(
        onTap: () {
          _onItemCheckedChange(item.value, !checked);
        },
        child: Row(
          children: [
            SizedBox(width: 10,),
            Checkbox(
              shape: CircleBorder(),
              checkColor: Colors.white,
              activeColor: AppTheme.almostBlack,
              value: checked,
              materialTapTargetSize: MaterialTapTargetSize.padded,
              onChanged: (checked) => _onItemCheckedChange(item.value, checked),
            ),
            Text(
              item.label,
              textAlign: TextAlign.left,
              style: TextStyle(
                color: AppTheme.almostBlack,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
          ],
        ),
      );
      CheckboxListTile(
      value: checked,
      title: Text(item.label),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) => _onItemCheckedChange(item.value, checked),
    );
  }
}

// ===================
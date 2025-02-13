import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class JsonFormWidget extends StatefulWidget {
  Map<dynamic, dynamic> jsonSchema;
  JsonFormWidget({Key? key, required this.jsonSchema}) : super(key: key);

  @override
  State<JsonFormWidget> createState() => _JsonFormWidgetState();
}

class _JsonFormWidgetState extends State<JsonFormWidget> {
  Map<dynamic, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _imageBase64 = {};
  Map<String, dynamic> tempData = {};
  List<dynamic> arraydata = [];
  Map<String, dynamic> tempArrayData = {};

  //for pick the image and convert into base64 format
  Future<void> _pickImage(String fieldKey) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image =
          "data:image/png;base64," + base64Encode(imageBytes);

      _imageBase64[fieldKey] = base64Image;
      // _formData[fieldKey] = base64Image;
    }
  }

  Widget buildFormfield(
      Map<dynamic, dynamic> jsonSchema, Map<dynamic, dynamic> form_data) {
    return Column(
        children: jsonSchema.entries.map((entry) {
          String key = entry.key;
          Map<String, dynamic> field = entry.value;
          if (field is Map<String, dynamic> && field.containsKey("type")) {
            String fieldType = field["type"];
            if (fieldType == "string" && key != "@type") {
              if (field["enum"] != null) {
                form_data[key] = "";
                return jsonDropDownField(key, field, form_data);
              } else if (field["format"] == "date") {
                form_data[key] = "";
                _controllers[key] = TextEditingController();
                return buildDatePickerField(key);
              } else if (field["format"] == "image") {
                form_data[key] = "";
                _imageBase64[key] = "";
                return jsonImagePicker(key);
              } else if (field.containsKey("default")) {
                form_data[key] = field["default"];
              } else {
                _controllers[key] = TextEditingController();
                form_data[key] = "";
                return jsonTextFormField(key);
              }
            } else if (key == "@type" && field.containsKey("default")) {
              form_data[key] = field["default"];
            } else if (fieldType == "boolean") {
              form_data[key] = false;
              return buildCheckboxField(key);
            } else if (fieldType == "array") {
              if (field.containsKey("default")) {
                form_data[key] = field["default"];
              } else if (key == "@context" && field["items"]["oneOf"] != null) {
                form_data[key] = [];
                for (var item in field["items"]["oneOf"]) {
                  if (item.containsKey("default")) {
                    form_data[key].add(item["default"]);
                  } else if (item.containsKey("properties")) {
                    Map<dynamic, dynamic> newItem = {};
                    buildFormfield(item["properties"], newItem);
                    form_data[key].add(newItem);
                  }
                }
              }
              if (key != "@type" && key != "@context") {
                form_data[key] = [];
                return _buildArrayField(key, field["items"], form_data);
              }
            } else if (fieldType == "object" && field.containsKey("properties")) {
              form_data[key] = {};
              return jsonObjectForm(key, field, form_data);
            }
          }
          // print(_controllers);
          return Container();
        }).toList());
  }

  Widget jsonTextFormField(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: key,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "this $key is required";
          }
          return null;
        },
      ),
    );
  }

  Widget jsonImagePicker(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key.toUpperCase(),
              style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _imageBase64[key] != null && _imageBase64[key]!.isNotEmpty
                  ? Image.memory(
                  base64Decode(_imageBase64[key]!.split(',')[1]),
                  height: 100)
                  : Container(
                height: 100,
                width: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.image, size: 50),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Pick Image"),
                onPressed: () => _pickImage(key),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget jsonDropDownField(String fieldKey, Map<dynamic, dynamic> fieldProperties,
      Map<dynamic, dynamic> parentData) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          labelText: fieldKey,
        ),
        value: (parentData[fieldKey] != null &&
            (fieldProperties["enum"] as List<dynamic>)
                .contains(parentData[fieldKey]))
            ? parentData[fieldKey] as String
            : null,
        onChanged: (newValue) {
          tempData[fieldKey] = newValue;
        },
        items: (fieldProperties["enum"] as List<dynamic>)
            .toSet()
            .map<DropdownMenuItem<String>>(
              (item) => DropdownMenuItem<String>(
            value: item.toString(),
            child: Text(item.toString()),
          ),
        )
            .toList(),
        validator: (value) => value == null ? "Please select $fieldKey" : null,
      ),
    );
  }

  Widget buildDatePickerField(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
          labelText: key,
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) {
                _controllers[key]?.text =
                pickedDate.toIso8601String().split('T')[0];
              }
            },
          ),
        ),
        readOnly: true,
        validator: (value) =>
        (value == null || value.isEmpty) ? "Please select a date" : null,
      ),
    );
  }

  Widget jsonObjectForm(String key, Map<dynamic, dynamic> field,
      Map<dynamic, dynamic> formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key.toUpperCase(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        buildFormfield(field["properties"], formData[key]),
      ],
    );
  }

  Widget buildCheckboxField(String key) {
    return CheckboxListTile(
      title: Text(key),
      value: tempData[key] ?? false,
      onChanged: (bool? value) {
        setState(() {
          tempData[key] = value;
        });
      },
    );
  }

  Widget _buildArrayField(String key, Map<dynamic, dynamic> jsonSchema,
      Map<dynamic, dynamic> formData) {
    tempArrayData[key] = {};
    return Column(
      children: [
        Text(key),
        if (arraydata.isNotEmpty) buildCardWidget(key),
        buildFormfield(jsonSchema["properties"], tempArrayData[key]),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
                onPressed: () {
                  updateArrayData(jsonSchema["properties"], key);
                },
                child: const Text('Save&Add')),
            TextButton(onPressed: () {}, child: const Text('Delete')),
          ],
        )
      ],
    );
  }

  Widget buildCardWidget(String key) {
    return Column(
      children: arraydata.map((item) {
        if (item is Map && item.containsKey(key)) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(item[key].toString()),
            ),
          );
        } else {
          return Container();
        }
      }).toList(),
    );
  }

  updateArrayData(Map<dynamic, dynamic> jsonData, String key) {
    Map<String, dynamic> newItemData = {};
    for (String keys in jsonData.keys) {
      if (jsonData[keys]["type"] == "string" &&
          !jsonData[keys].containsKey("default")) {
        if (jsonData[keys].containsKey("enum")) {
          newItemData[keys] = tempData[keys] ?? "";
        } else {
          newItemData[keys] = _controllers[keys]?.text ?? "";
        }
      }
    }
    Map<dynamic, dynamic> newItem = {};
    newItem[key] = newItemData;
    setState(() {
      arraydata.add(newItem);
    });
  }

  // update data into _formData

  void updateSubmitedData(
      Map<dynamic, dynamic> jsonData, Map<dynamic, dynamic> fromData) {
    for (String key in jsonData.keys) {
      if (jsonData[key]["type"] == "string" && jsonData[key]["enum"] != null) {
        if (key != "@type") {
          fromData[key] = tempData[key] ?? "";
        }
      } else if (jsonData[key]["type"] == "string" &&
          jsonData[key]["format"] == "date") {
        fromData[key] = _controllers[key]?.text ?? "";
      } else if (jsonData[key]["type"] == "string" && key != "@type") {
        fromData[key] = _controllers[key]?.text ?? "";
      } else if (jsonData[key]["type"] == "string" &&
          jsonData[key]["format"] == "image") {
        fromData[key] = _imageBase64[key];
      } else if (jsonData[key]["type"] == "boolean") {
        fromData[key] = tempData[key] ?? "";
      } else if (jsonData[key]["type"] == "array") {
        if (key != "@context" && key != "@type") {
          fromData[key] = []; // Initialize the array
          for (var item in arraydata) {
            if (item is Map && item.containsKey(key)) {
              fromData[key].add(item[key]);
            }
          }
        }
      } else if (jsonData[key]["type"] == "object") {
        if (fromData[key] == null) {
          fromData[key] = {};
        }
        updateSubmitedData(jsonData[key]["properties"], fromData[key]);
      }
    }
  }

  void _submitForm() async {
    updateSubmitedData(widget.jsonSchema, _formData);
    print("Submitted Data: $_formData");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildFormfield(widget.jsonSchema, _formData),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
                style: ButtonStyle(
                    shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    )),
                    backgroundColor: const WidgetStatePropertyAll(Colors.blue)),
                onPressed: _submitForm,
                child: const Text('Upload',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white))),
          ),
        )
      ],
    );
  }
}

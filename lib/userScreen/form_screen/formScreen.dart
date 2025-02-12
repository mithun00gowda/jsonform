import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../screen/jsonload.dart';

class Formscreen extends StatefulWidget {
  var jsonSchema;
   Formscreen({super.key,this.jsonSchema});

  @override
  State<Formscreen> createState() => _FormscreenState();
}

class _FormscreenState extends State<Formscreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<dynamic, TextEditingController> _controllers = {};
  final Map<String, String> _imageBase64 = {}; // Store images in Base64 format
  final Map<dynamic, dynamic> _formData = {};
  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  /// **Initialize Controllers & Form Data**
  void _initializeControllers() {
    _initializeFields(widget.jsonSchema, _formData);
  }

  void _initializeFields(Map<dynamic, dynamic> fields, Map<dynamic, dynamic> parentData) {
    for (String key in fields.keys) {
      var field = fields[key];
      print(key);
      if (field["type"] == "string") {
        if (field["format"] == "image") {
          _imageBase64[key] = "";
          parentData[key] = "";
        } else if (key == "@type" && field.containsKey("default")) {
          parentData[key] = field["default"];
        } else {
          _controllers[key] = TextEditingController(text: field["default"] ?? "");
          parentData[key] = field["default"] ?? "";
        }
      } else if (field["type"] == "boolean") {
        parentData[key] = field.containsKey("default") ? field["default"] : false;
      } else if (field["type"] == "array") {


        if (field.containsKey("default")) {
          parentData[key] = field["default"];
        } else if (key == "@context" && field["items"]["oneOf"] != null) {
          // Handle @context array initialization
          parentData[key] = [];
          for (var item in field["items"]["oneOf"]) {
            if (item.containsKey("default")) {
              parentData[key].add(item["default"]);
            } else if (item.containsKey("properties")) {
              Map<dynamic, dynamic> newItem = {};
              _initializeFields(item["properties"], newItem);
              parentData[key].add(newItem);
            }
          }
        } else if (field["items"].containsKey("properties")) {
          List<Map<dynamic, dynamic>> initializedArray = [];
          parentData[key] = initializedArray;
        }
      } else if (field["type"] == "object") {
        parentData[key] = {};
        _initializeFields(field["properties"], parentData[key]);
      }
    }
    print(_formData);
  }





  //build form form the json Schema
  // Widget buildForm(Map<dynamic,dynamic> jsonData,Map<dynamic,dynamic> parentData){
  //   return Column(
  //     children: jsonData.entries.map((entry){
  //       String keys = entry.key;
  //       Map<dynamic,dynamic> fields = entry.value;
  //       print(fields);
  //       if(fields['type'] == 'object'){
  //        return buildForm(fields['properties'],parentData);
  //       }else if(fields['type'] == 'string'){
  //         return Text('String');
  //       }else if(fields['type'] == 'array'){
  //         return Text('array');
  //       }else{
  //         return Column(
  //           children: [
  //             Container()
  //           ],
  //         );
  //       }
  //     }).toList(),
  //   );
  // }

  Future<void> _pickImage(String fieldKey) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = "data:image/png;base64," + base64Encode(imageBytes);

      setState(() {
        _imageBase64[fieldKey] = base64Image;
        _formData[fieldKey] = base64Image;
      });
    }
  }

  /// **Builds the Form Fields Dynamically**
  Widget buildForm(Map<dynamic, dynamic> jsonData) {
    // print("form Data ${_formData}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: jsonData.entries.map((entry) {
        String key = entry.key;
        var field = entry.value;

        if(key != "@context"){
          if (field is Map<String, dynamic> && field.containsKey("type")) {
            String fieldType = field["type"];

            if (fieldType == "string" && key != "@type") {
              if (field["enum"] != null) {
                return buildDropdownField(key, field["enum"]);
              } else if (field["format"] == "date") {
                return buildDatePickerField(key,field);
              } else if (field["format"] == "image") {
                return buildImagePickerField(key);
              } else {
                return buildTextInputField(key,field);
              }
            } else if (fieldType == "boolean") {
              return buildCheckboxField(key);
            } else if (fieldType == "array" && field.containsKey("items")) {
              return _buildArrayField(key, field["items"]);
            } else if (fieldType == "object" && field.containsKey("properties")) {
              return buildObjectField(key, field["properties"]);
            }
          }
        }
        return Container();
      }).toList(),
    );
  }

  /// **Text Input Field**
  Widget buildTextInputField(String key,Map<dynamic,dynamic> datafeilds) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(
          labelText: key,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
        ),
        validator: (value) {
          if (value!.trim().isEmpty) {
            return "this $key is required";
          }
          return null;
        },
      ),
    );
  }

  /// **Dropdown Field (Enum)**
  Widget buildDropdownField(String key, List<dynamic> values) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          labelText: key,
        ),
        items: (values)
            .toSet() // Remove duplicates
            .map<DropdownMenuItem<String>>(
              (item) =>
              DropdownMenuItem<String>(
                value: item.toString(),
                child: Text(item.toString()),
              ),
        ).toList(),
        onChanged: (newValue) {
          setState(() {
            _formData[key] =
                newValue; // Ensure _formData updates properly
          });
          print(_formData);
        },

        validator: (value) =>
        value == null
            ? "Please select $key"
            : null,
      ),
    );;
  }

  /// **Date Picker Field**
  Widget buildDatePickerField(String key,Map<dynamic,dynamic> datafeilds) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
          controller: _controllers[key],
          decoration: InputDecoration(
            labelText: key,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
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
                  setState(() {
                    _controllers[key]!.text = pickedDate.toIso8601String().split('T')[0];
                    // _formData[key] = _controllers[key]!.text;
                  });
                }

              },
            ),
          ),
          readOnly: true,
          validator: (value){
            if(value == null){
              return "this $key is required";
            }
            return null;
          }
      ),
    );
  }

  /// **Image Picker Field**
  Widget buildImagePickerField(String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(key, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _imageBase64[key] != null && _imageBase64[key]!.isNotEmpty
              ? Image.memory(base64Decode(_imageBase64[key]!.split(',')[1]), height: 100)
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
      ),
    );
  }

  /// **Checkbox Field**
  Widget buildCheckboxField(String key) {
    return CheckboxListTile(
      title: Text(key),
      value: _formData[key] ?? false,
      onChanged: (bool? value) {
        setState(() {
          _formData[key] = value;
        });
      },
    );
  }

  Widget additemsData(jsonSchema){
    return Column(
      children: [
        buildForm(jsonSchema['properties'])
      ],
    );
  }

  Widget _buildArrayField(String fieldName, Map<String, dynamic> itemSchema) {
    return StatefulBuilder(
      builder: (context, setState) {
        if (!_formData['jsonSchema']['credentialSubject'].containsKey(fieldName) || _formData['jsonSchema']['credentialSubject'][fieldName] == null) {
          _formData[fieldName] = []; // Ensure array is initialized
        }

        List<dynamic> arrayItems = _formData['jsonSchema']['credentialSubject'][fieldName];
        print(_formData['jsonSchema']['credentialSubject'][fieldName]);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(fieldName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      if (itemSchema['type'] == 'object' && itemSchema.containsKey('properties')) {
                        Map<dynamic, dynamic> newItem = {};
                        _initializeFields(itemSchema['properties'], newItem);
                        arrayItems.add(newItem);
                      } else {
                        arrayItems.add(""); // Default empty value for non-object arrays
                      }
                    });
                  },
                  child: Text('Add'),
                ),
              ],
            ),
            Column(
              children: List.generate(arrayItems.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildForm(itemSchema['properties']),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            arrayItems.removeAt(index);
                          });
                        },
                      ),
                    ),
                    Divider(), // Separate each array item visually
                  ],
                );
              }),
            ),
          ],
        );
      },
    );
  }


  Widget buildObjectField(String key, Map<String, dynamic> properties) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(key, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        buildForm(properties),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildForm(widget.jsonSchema)
          ],
        ),
      ),
    );
  }
}

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class NutritionAssistPage extends StatefulWidget {
//   const NutritionAssistPage({super.key});

//   @override
//   _NutritionAssistPageState createState() => _NutritionAssistPageState();
// }

// class _NutritionAssistPageState extends State<NutritionAssistPage> {
//   List<Map<String, dynamic>> children = [];
//   String? selectedChildId;
//   List<Map<String, String>> nutritionSuggestions = [];
//   TextEditingController followUpController = TextEditingController();
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchChildren();
//   }

//   Future<void> fetchChildren() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? parentId = prefs.getString('userId');

//     final response = await http.get(
//       Uri.parse('http://127.0.0.1:8000/children/?parentId=$parentId'),
//       headers: {"Content-Type": "application/json"},
//     );

//     if (response.statusCode == 200) {
//       setState(() {
//         children = List<Map<String, dynamic>>.from(jsonDecode(response.body));
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to fetch children.')),
//       );
//     }
//   }

//   Future<void> fetchNutritionSuggestions(String childId) async {
//     setState(() {
//       isLoading = true;
//     });

//     final selectedChild = children.firstWhere(
//       (child) => child['id'] == childId,
//       orElse: () => {},
//     );

//     if (selectedChild.isEmpty) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Selected child data not found.')),
//       );
//       return;
//     }

//     try {
//       final response = await http.post(
//         Uri.parse('http://127.0.0.1:8000/nutrition/'),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "date_of_birth": selectedChild['date_of_birth'],
//           "weight": selectedChild['weight'],
//           "height": selectedChild['height'],
//           "milestones": selectedChild['milestones'] ?? [],
//           "allergies": selectedChild['allergies'],
//           "gender": selectedChild['gender'],
//         }),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['diet_plan'] != null) {
//           setState(() {
//             nutritionSuggestions = [];
//             if (data['diet_plan']['general_advice'] != null) {
//               nutritionSuggestions.add({
//                 "title": "General Advice",
//                 "content": data['diet_plan']['general_advice'][0]['content']
//               });
//             }

//             if (data['diet_plan']['diet_suggestions'] != null) {
//               nutritionSuggestions.addAll(
//                 (data['diet_plan']['diet_suggestions'] as List<dynamic>)
//                     .map((section) {
//                   final sectionMap = Map<String, dynamic>.from(section);
//                   return {
//                     "title": sectionMap['title']?.toString() ?? '',
//                     "content": sectionMap['content']?.toString() ?? '',
//                   };
//                 }).toList(),
//               );
//             }
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('No nutrition suggestions available.')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Failed to fetch nutrition suggestions.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> sendFollowUp(String question) async {
//     setState(() {
//       isLoading = true;
//     });

//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:8000/nutrition/follow-up/'),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"question": question}),
//     );

//     setState(() {
//       isLoading = false;
//     });
//     if (response.statusCode == 200) {
//       final content =
//           response.body.isNotEmpty ? response.body : 'No response from server.';
//       setState(() {
//         nutritionSuggestions.add({
//           "title": "Follow-up: $question",
//           "content": content,
//         });
//         followUpController.clear();
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to send follow-up question.')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Nutrition Assist'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Select Child',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.blueAccent),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 10),
//               child: DropdownButton<String>(
//                 value: selectedChildId,
//                 hint: const Text('Select a child'),
//                 items: children.map((child) {
//                   return DropdownMenuItem<String>(
//                     value: child['id'],
//                     child: Text(child['name']),
//                   );
//                 }).toList(),
//                 isExpanded: true,
//                 onChanged: (value) {
//                   setState(() {
//                     selectedChildId = value;
//                     fetchNutritionSuggestions(value!);
//                   });
//                 },
//                 underline: const SizedBox(),
//               ),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Nutrition Suggestions',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[100],
//                   borderRadius: BorderRadius.circular(12),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       blurRadius: 8,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 padding: const EdgeInsets.all(16),
//                 child: isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : nutritionSuggestions.isEmpty
//                         ? const Center(
//                             child: Text(
//                               'No suggestions available.',
//                               style: TextStyle(fontSize: 16),
//                             ),
//                           )
//                         : ListView.builder(
//                             itemCount: nutritionSuggestions.length,
//                             itemBuilder: (context, index) {
//                               final section = nutritionSuggestions[index];
//                               return Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(vertical: 8.0),
//                                 child: Card(
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                   elevation: 4,
//                                   child: ListTile(
//                                     title: Text(
//                                       section['title'] ?? '',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     subtitle: Text(section['content'] ?? ''),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//               ),
//             ),
//             const Divider(),
//             const Text(
//               'Ask Follow-up Question',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: followUpController,
//                     decoration: InputDecoration(
//                       labelText: 'Type your question...',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     sendFollowUp(followUpController.text);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text('Send'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NutritionAssistPage extends StatefulWidget {
  const NutritionAssistPage({super.key});

  @override
  _NutritionAssistPageState createState() => _NutritionAssistPageState();
}

class _NutritionAssistPageState extends State<NutritionAssistPage> {
  List<Map<String, dynamic>> children = [];
  String? selectedChildId;
  List<Map<String, String>> nutritionSuggestions = [];
  TextEditingController followUpController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchChildren();
  }

  Future<void> fetchChildren() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? parentId = prefs.getString('userId');

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/children/?parentId=$parentId'),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      setState(() {
        children = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch children.')),
      );
    }
  }

  Future<void> fetchNutritionSuggestions(String childId) async {
    setState(() {
      isLoading = true;
    });

    final selectedChild = children.firstWhere(
      (child) => child['id'] == childId,
      orElse: () => {},
    );

    if (selectedChild.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected child data not found.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/nutrition/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "date_of_birth": selectedChild['date_of_birth'],
          "weight": selectedChild['weight'],
          "height": selectedChild['height'],
          "milestones": selectedChild['milestones'] ?? [],
          "allergies": selectedChild['allergies'],
          "gender": selectedChild['gender'],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['diet_plan'] != null) {
          setState(() {
            nutritionSuggestions = [];

            // Process General Advice
            // if (data['diet_plan']['general_advice'] != null) {
            //   nutritionSuggestions.add({
            //     "title": "General Advice",
            //     "content": data['diet_plan']['general_advice']
            //         .map((advice) => advice['content'])
            //         .join("\n\n")
            //   });
            // }
            // if (data['diet_plan']['general_advice'] != null) {
            //   final generalAdviceContent = data['diet_plan']['general_advice']
            //       .map((advice) => advice['content'])
            //       .join("\n\n");
            //   nutritionSuggestions.add(
            //       {"title": "General Advice", "content": generalAdviceContent});
            // }

            // if (data['diet_plan']['general_advice'] != null) {
            //   nutritionSuggestions.add({
            //     "title": "General Advice",
            //     "content": data['diet_plan']['general_advice']
            //         .map((advice) => advice['content'])
            //         .join("\n\n"),
            //   });
            // }
            // if (data['diet_plan']['diet_suggestions'] != null) {
            //   nutritionSuggestions.addAll(
            //     (data['diet_plan']['diet_suggestions'] as List<dynamic>)
            //         .map((section) {
            //       final sectionMap = Map<String, dynamic>.from(section);
            //       return {
            //         "title": sectionMap['title']?.toString() ?? '',
            //         "content": sectionMap['content']?.toString() ?? '',
            //       };
            //     }).toList(),
            //   );
            // }
            // Process Diet Plan
            // if (data['diet_plan'] != null) {
            //   final dietPlanSections = [];
            //   if (data['diet_plan']['diet_suggestions'] != null) {
            //     dietPlanSections.addAll(
            //       (data['diet_plan']['diet_suggestions'] as List<dynamic>)
            //           .map((section) {
            //         final sectionMap = Map<String, dynamic>.from(section);
            //         return {
            //           "title": sectionMap['title']?.toString() ?? '',
            //           "content": sectionMap['content']?.toString() ?? '',
            //         };
            //       }).toList(),
            //     );
            //   }
            //   nutritionSuggestions.add({
            //     "title": "Diet Plan",
            //     "content": dietPlanSections
            //         .map((section) =>
            //             "${section['title']}:\n${section['content']}")
            //         .join("\n\n"),
            //   });
            // }

            // Combine General Advice and Sample Diet Plan into a single entry
            if (data['diet_plan']['general_advice'] != null ||
                data['diet_plan']['sample_plan'] != null) {
              final generalContent = [];

              // Add General Advice
              if (data['diet_plan']['general_advice'] != null) {
                generalContent.add(
                  "General Advice:\n${data['diet_plan']['general_advice'].map((advice) => advice['content']).join("\n\n")}",
                );
              }

              // Add Sample Diet Plan
              if (data['diet_plan']['sample_plan'] != null) {
                generalContent.add(
                  "Sample Diet Plan (Adjust based on your child's preferences and pediatrician's advice):\n${data['diet_plan']['sample_plan']}",
                );
              }

              nutritionSuggestions.add({
                // "title": "General Advice & Sample Plan",
                "content": generalContent.join("\n\n"),
              });
            }

            // Process the actual Diet Plan
            if (data['diet_plan']['diet_suggestions'] != null) {
              final dietPlanContent = data['diet_plan']['diet_suggestions']
                  .map((section) {
                    final sectionMap = Map<String, dynamic>.from(section);
                    return "${sectionMap['title']?.toString() ?? ''}:\n${sectionMap['content']?.toString() ?? ''}";
                  })
                  .toList()
                  .join("\n\n");

              nutritionSuggestions.add({
                // "title": "Diet Plan",
                "content": dietPlanContent,
              });
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('No nutrition suggestions available.')),
          );
        }

        // setState(() {
        //   nutritionSuggestions = [];
        //   if (data['diet_plan'] != null) {
        //     if (data['diet_plan']['general_advice'] != null) {
        //       nutritionSuggestions.add({
        //         "title": "General Advice",
        //         "content": data['diet_plan']['general_advice'][0]['content'],
        //       });
        //     }
        //     //
        //     if (data['diet_plan']['diet_suggestions'] != null) {
        //       nutritionSuggestions.addAll(
        //         (data['diet_plan']['diet_suggestions'] as List<dynamic>)
        //             .map((section) {
        //           final sectionMap = Map<String, dynamic>.from(section);
        //           return {
        //             "title": sectionMap['title']?.toString() ?? '',
        //             "content": sectionMap['content']?.toString() ?? '',
        //           };
        //         }).toList(),
        //       );
        //     }
        //   }
        // }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to fetch nutrition suggestions.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendFollowUp(String question) async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/nutrition/follow-up/'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"question": question}),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final content =
          response.body.isNotEmpty ? response.body : 'No response from server.';
      setState(() {
        nutritionSuggestions.add({
          "title": "Follow-up: $question",
          "content": content,
        });
        followUpController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send follow-up question.')),
      );
    }
  }

  Widget _buildFormattedContent(String content) {
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        if (line.startsWith('* ')) {
          return Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(child: Text(line.substring(2))),
              ],
            ),
          );
        } else if (line.startsWith('')) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              line.replaceAll('', ''),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(line),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Nutrition Assist',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Plus Jakarta Sans',
                color: Colors.white),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Child',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: selectedChildId,
                  hint: const Text('Select a child'),
                  items: children.map((child) {
                    return DropdownMenuItem<String>(
                      value: child['id'],
                      child: Text(child['name']),
                    );
                  }).toList(),
                  isExpanded: true,
                  onChanged: (value) {
                    setState(() {
                      selectedChildId = value;
                      fetchNutritionSuggestions(value!);
                    });
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nutrition Suggestions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : nutritionSuggestions.isEmpty
                            ? const Center(
                                child: Text('No suggestions available.'))
                            : ListView.builder(
                                itemCount: nutritionSuggestions.length,
                                itemBuilder: (context, index) {
                                  final section = nutritionSuggestions[index];
                                  return Card(
                                    elevation: 4,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: ListTile(
                                      title: Text(
                                        section['title'] ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: _buildFormattedContent(
                                          section['content']!),
                                    ),
                                  );
                                },
                              ),
                  ),
                ),
                const Divider(),
                const Text(
                  'Ask Follow-up Question',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: followUpController,
                        decoration: InputDecoration(
                          labelText: 'Type your question...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        sendFollowUp(followUpController.text);
                      },
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}

// ----------------------------------------------------------------------------------------------------------------------------------------------------------
// if (data['diet_plan']['diet_suggestions'] != null) {
//   nutritionSuggestions.addAll(
//     (data['diet_plan']['diet_suggestions'] as List<dynamic>)
//         .map((section) => {
//               "title": section['title'],
//               "content": section['content']
//             })
//         .toList(),
//   );
// }

// Future<void> fetchNutritionSuggestions(String childId) async {
//   setState(() {
//     isLoading = true;
//   });

//   final selectedChild = children.firstWhere(
//     (child) => child['id'] == childId,
//     orElse: () => {},
//   );

//   if (selectedChild.isEmpty) {
//     setState(() {
//       isLoading = false;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Selected child data not found.')),
//     );
//     return;
//   }

//   try {
//     final response = await http.post(
//       Uri.parse('http://127.0.0.1:8000/nutrition/'),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({
//         "date_of_birth": selectedChild['date_of_birth'],
//         "weight": selectedChild['weight'],
//         "height": selectedChild['height'],
//         "milestones": selectedChild['milestones'] ?? [],
//         "allergies": selectedChild['allergies'],
//         "gender": selectedChild['gender'],
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['diet_plan'] != null &&
//           data['diet_plan']['sections'] != null) {
//         setState(() {
//           nutritionSuggestions =
//               (data['diet_plan']['sections'] as List<dynamic>).map((section) {
//             return Map<String, String>.from(section as Map<String, dynamic>);
//           }).toList();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('No nutrition suggestions available.')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Failed to fetch nutrition suggestions.')),
//       );
//     }
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error: $e')),
//     );
//   } finally {
//     setState(() {
//       isLoading = false;
//     });
//   }
// }
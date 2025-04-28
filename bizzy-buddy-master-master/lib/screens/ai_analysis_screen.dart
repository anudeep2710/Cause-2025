// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../controllers/dashboard_controller.dart';

// class AIAnalysisScreen extends ConsumerStatefulWidget {
//   const AIAnalysisScreen({Key? key}) : super(key: key);

//   @override
//   _AIAnalysisScreenState createState() => _AIAnalysisScreenState();
// }

// class _AIAnalysisScreenState extends ConsumerState<AIAnalysisScreen> {
//   final TextEditingController _questionController = TextEditingController();
//   String _answer = '';
//   bool _isLoading = false;
//   List<Map<String, String>> _recentQuestions = [
//     {'question': 'What are my best-selling products?', 'answer': ''},
//     {'question': 'How has my revenue changed in the last month?', 'answer': ''},
//     {'question': 'What day of the week has the highest sales?', 'answer': ''},
//     {'question': 'What product category is most profitable?', 'answer': ''},
//   ];

//   @override
//   void dispose() {
//     _questionController.dispose();
//     super.dispose();
//   }

//   Future<void> _analyzeData() async {
//     final question = _questionController.text.trim();
//     if (question.isEmpty) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final controller = ref.read(dashboardControllerProvider);
//       final result = await controller.analyzeData(question);

//       setState(() {
//         _answer = result;
//         _isLoading = false;
//         // Add to recent questions
//         _recentQuestions.insert(0, {'question': question, 'answer': result});
//         if (_recentQuestions.length > 10) {
//           _recentQuestions.removeLast();
//         }
//       });

//       _questionController.clear();
//     } catch (e) {
//       setState(() {
//         _answer = 'Error: $e';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('AI Business Analysis'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.help_outline),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('AI Analysis Help'),
//                   content: const SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                             'You can ask questions about your business data such as:'),
//                         SizedBox(height: 8),
//                         Text('• "What are my top selling products?"'),
//                         Text('• "How has my revenue changed over time?"'),
//                         Text('• "When is my busiest time of day?"'),
//                         Text(
//                             '• "Which product categories have the highest profit margins?"'),
//                         Text('• "What inventory should I restock soon?"'),
//                         SizedBox(height: 8),
//                         Text(
//                             'The AI will analyze your business data and provide insights.'),
//                       ],
//                     ),
//                   ),
//                   actions: [
//                     TextButton(
//                       onPressed: () => Navigator.pop(context),
//                       child: const Text('OK'),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text(
//               'Ask a question about your business',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _questionController,
//               decoration: InputDecoration(
//                 hintText: 'e.g., What are my top selling products?',
//                 border: const OutlineInputBorder(),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.send),
//                   onPressed: _analyzeData,
//                 ),
//               ),
//               onSubmitted: (_) => _analyzeData(),
//               maxLines: 2,
//               textInputAction: TextInputAction.newline,
//             ),
//             const SizedBox(height: 24),
//             if (_isLoading)
//               const Center(child: CircularProgressIndicator())
//             else if (_answer.isNotEmpty)
//               Expanded(
//                 child: Card(
//                   elevation: 2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Analysis Result:',
//                             style: Theme.of(context)
//                                 .textTheme
//                                 .titleMedium
//                                 ?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _answer,
//                             style: Theme.of(context).textTheme.bodyLarge,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//             else
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Suggested Questions:',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: _recentQuestions.length,
//                         itemBuilder: (context, index) {
//                           return Card(
//                             elevation: 1,
//                             margin: const EdgeInsets.only(bottom: 8),
//                             child: ListTile(
//                               title: Text(_recentQuestions[index]['question']!),
//                               subtitle:
//                                   _recentQuestions[index]['answer']!.isNotEmpty
//                                       ? Text(_recentQuestions[index]['answer']!,
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis)
//                                       : null,
//                               onTap: () {
//                                 _questionController.text =
//                                     _recentQuestions[index]['question']!;
//                               },
//                               trailing:
//                                   const Icon(Icons.arrow_forward_ios, size: 16),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

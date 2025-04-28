// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart';
// import '../../widgets/custom_badge.dart';

// class SustainabilityScreen extends StatelessWidget {
//   const SustainabilityScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sustainability'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => context.pop(),
//         ),
//       ),
//       body: Consumer<SustainabilityProvider>(
//         builder: (context, provider, child) {
//           if (provider.isLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Your Green Impact',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 const SizedBox(height: 16),
//                 Card(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Carbon Footprint',
//                           style: Theme.of(context).textTheme.titleLarge,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           '${provider.carbonFootprint.toStringAsFixed(2)} kg CO₂',
//                           style: Theme.of(context)
//                               .textTheme
//                               .headlineMedium
//                               ?.copyWith(
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'This represents your total carbon emissions from business operations.',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Your Badges',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                 ),
//                 const SizedBox(height: 16),
//                 GridView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     childAspectRatio: 0.8,
//                     crossAxisSpacing: 16,
//                     mainAxisSpacing: 16,
//                   ),
//                   itemCount: provider.badges.length,
//                   itemBuilder: (context, index) {
//                     final badge = provider.badges[index];
//                     return CustomBadge(
//                       iconPath: badge.iconPath,
//                       name: badge.name,
//                       description: badge.description,
//                       points: badge.points,
//                       earnedAt: badge.earnedAt,
//                       isNew: badge.earnedAt.isAfter(
//                         DateTime.now().subtract(const Duration(days: 7)),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

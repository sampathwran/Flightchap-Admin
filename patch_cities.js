const fs = require('fs');
const file = 'lib/screens/popular_destinations_screen.dart';
let content = fs.readFileSync(file, 'utf8');

// Replace controller declarations
content = content.replace(
  /final startingPriceController = .*?;\\s*final bestTimeController = .*?;\\s*final tagsController = .*?;\\s*final ratingController = .*?;\\s*final reviewsController = .*?;/s,
  inal startingPriceController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('startingPrice') ? document['startingPrice'] : '');
    final durationController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('duration') ? document['duration'] : '');
    final airlinesController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('airlines') ? document['airlines'] : '');
    final baggageController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('baggage') ? document['baggage'] : '');
    final stopoversController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('stopovers') ? document['stopovers'] : '');
    final tagsController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('tags') ? document['tags'] : '');
);

// Replace TextFields in dialog
content = content.replace(
  /TextField\\(controller: startingPriceController.*?TextField\\(controller: reviewsController.*?\\),/s,
  TextField(controller: startingPriceController, decoration: const InputDecoration(labelText: 'Starting Flight Price (\$) (e.g. 250)')),
                      TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Flight Duration (e.g. 4h 30m)')),
                      TextField(controller: airlinesController, decoration: const InputDecoration(labelText: 'Airlines (e.g. Emirates, Qatar)')),
                      TextField(controller: baggageController, decoration: const InputDecoration(labelText: 'Baggage Allowance (e.g. 30kg)')),
                      TextField(controller: stopoversController, decoration: const InputDecoration(labelText: 'Stopovers (e.g. Direct, 1 Stop)')),
                      TextField(controller: tagsController, decoration: const InputDecoration(labelText: 'Tags (comma separated, e.g. ??? Beaches, ?? Direct)')),
);

// Replace Firestore map
content = content.replace(
  /'startingPrice': startingPriceController.text,\\s*'bestTime': bestTimeController.text,\\s*'tags': tagsController.text,\\s*'image': finalImageUrl,\\s*'rating': ratingController.text,\\s*'reviews': reviewsController.text,/s,
  'startingPrice': startingPriceController.text,
                        'duration': durationController.text,
                        'airlines': airlinesController.text,
                        'baggage': baggageController.text,
                        'stopovers': stopoversController.text,
                        'tags': tagsController.text,
                        'image': finalImageUrl,
);

fs.writeFileSync(file, content);
console.log('Admin panel updated');

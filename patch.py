import re

with open('lib/screens/popular_destinations_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace controllers
content = re.sub(
    r"final startingPriceController = [^\n]+\n[^\n]*bestTimeController = [^\n]+\n[^\n]*tagsController = [^\n]+\n[^\n]*ratingController = [^\n]+\n[^\n]*reviewsController = [^\n]+",
    '''final startingPriceController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('startingPrice') ? document['startingPrice'] : '');
    final durationController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('duration') ? document['duration'] : '');
    final airlinesController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('airlines') ? document['airlines'] : '');
    final baggageController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('baggage') ? document['baggage'] : '');
    final stopoversController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('stopovers') ? document['stopovers'] : '');
    final tagsController = TextEditingController(text: isEditing && (document.data() as Map<String, dynamic>).containsKey('tags') ? document['tags'] : '');''',
    content
)

# Replace TextFields
content = re.sub(
    r"TextField\(controller: startingPriceController[^;]+TextField\(controller: reviewsController, [^\n]+",
    '''TextField(controller: startingPriceController, decoration: const InputDecoration(labelText: 'Starting Flight Price ($) (e.g. 250)')),
                      TextField(controller: durationController, decoration: const InputDecoration(labelText: 'Flight Duration (e.g. 4h 30m)')),
                      TextField(controller: airlinesController, decoration: const InputDecoration(labelText: 'Airlines (e.g. Emirates, Qatar)')),
                      TextField(controller: baggageController, decoration: const InputDecoration(labelText: 'Baggage Allowance (e.g. 30kg)')),
                      TextField(controller: stopoversController, decoration: const InputDecoration(labelText: 'Stopovers (e.g. Direct, 1 Stop)')),
                      TextField(controller: tagsController, decoration: const InputDecoration(labelText: 'Tags (comma separated, e.g. ??? Beaches, ?? Direct)'))''',
    content
)

# Replace Firestore Map
content = re.sub(
    r"'startingPrice': startingPriceController.text,\n\s*'bestTime': bestTimeController.text,\n\s*'tags': tagsController.text,\n\s*'image': finalImageUrl,\n\s*'rating': ratingController.text,\n\s*'reviews': reviewsController.text,",
    ''''startingPrice': startingPriceController.text,
                        'duration': durationController.text,
                        'airlines': airlinesController.text,
                        'baggage': baggageController.text,
                        'stopovers': stopoversController.text,
                        'tags': tagsController.text,
                        'image': finalImageUrl,''',
    content
)

with open('lib/screens/popular_destinations_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("Done")

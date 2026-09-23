const fs = require('fs');

let content = fs.readFileSync('lib/screens/promo_codes_screen.dart', 'utf8');

// The validation block looks like:
/*
      if (_titleController.text.isEmpty || _codeController.text.isEmpty || _discountController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
      } else {
        bool hasImage = _selectedImageBytes != null || (_editingDealId != null && _imageUrlController.text.isNotEmpty);
        if (_selectedStartTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a start time.')));
        } else if (_selectedEndTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an end time.')));
        } else if (!hasImage) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide an Image.')));
        } else {
*/
// We just need to replace the complicated validation with simple validation!
content = content.replace(/bool hasImage =.*?\} else \{/s, "");
// Wait, the regex might be tricky. Let me just find the block.

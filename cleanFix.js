const fs = require('fs');

function cleanSubmit(file) {
  let content = fs.readFileSync(file, 'utf8');

  // Replace this EXACT string which blocks submission
  const oldCondition = `if (_formKey.currentState!.validate() && _selectedEndTime != null && hasImage) {`;
  const newCondition = `if (_formKey.currentState!.validate()) {`;
  content = content.replace(oldCondition, newCondition);
  
  // Replace the Time validation error
  const oldTimeCheck = `if (_selectedEndTime!.isBefore(effectiveStartTime)) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('End Time must be after Start Time.')));
        return;
      }`;
  const newTimeCheck = `// Time validation removed`;
  content = content.replace(oldTimeCheck, newTimeCheck);
  
  // Remove the dangling else block that showed snackbars
  const oldElse = `} else {
      if (_selectedEndTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an end time.')));
      } else if (!hasImage) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide an Image.')));
      }
    }`;
  content = content.replace(oldElse, `}`);

  fs.writeFileSync(file, content, 'utf8');
}

cleanSubmit('lib/screens/member_deals_screen.dart');
cleanSubmit('lib/screens/promo_codes_screen.dart');
console.log("Fixed cleanly");

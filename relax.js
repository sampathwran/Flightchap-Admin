const fs = require('fs');

function makeEasy(file) {
  let content = fs.readFileSync(file, 'utf8');

  // Change if (_formKey.currentState!.validate() && _selectedEndTime != null && hasImage) to just validate
  content = content.replace(
    /if \(_formKey\.currentState!\.validate\(\) && _selectedEndTime != null && hasImage\) \{/g,
    `if (_formKey.currentState!.validate()) {`
  );
  
  content = content.replace(
    /if \(_formKey\.currentState!\.validate\(\)\) \{/g,
    `if (true) {`
  ); // Wait, this might mess up the one I just replaced. Let me just do a manual replace.
  
  fs.writeFileSync(file, content, 'utf8');
}

// Just rewrite the validation block for both to be super permissive
function rewriteSubmit(file) {
  let content = fs.readFileSync(file, 'utf8');
  const submitBlock = content.match(/Future<void> _submitDeal\(\) async \{([\s\S]*?)bool\? confirm = await showDialog/)[1];
  
  const newSubmitBlock = `
    print("DEBUG BUTTON CLICKED: _submitDeal starting...");
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required text fields.')));
      return;
    }
    
    DateTime effectiveStartTime = _selectedStartTime ?? DateTime.now();
    DateTime effectiveEndTime = _selectedEndTime ?? DateTime.now().add(const Duration(days: 30));
    
    // `;
    
  content = content.replace(submitBlock, newSubmitBlock);
  fs.writeFileSync(file, content, 'utf8');
}

rewriteSubmit('lib/screens/member_deals_screen.dart');
rewriteSubmit('lib/screens/promo_codes_screen.dart');
console.log("Validation relaxed.");

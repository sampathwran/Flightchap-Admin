const fs = require('fs');

let code = fs.readFileSync('lib/screens/popular_destinations_screen.dart', 'utf8');

// The original map emoji in UTF-8
const mapEmoji = '🗺️';

if (code.includes(mapEmoji)) {
    code = code.replace(
        "document['flag'] : '🗺️';",
        "document['flag'] : _countryFlags[0]['flag']!;"
    );
    console.log("Replaced map emoji flag.");
} else {
    // maybe it got garbled as ðŸ—ºï¸
    code = code.replace(
        /document\['flag'\] \: '[^']+';/g,
        "document['flag'] : _countryFlags[0]['flag']!;"
    );
    console.log("Replaced any weird default flag.");
}

fs.writeFileSync('lib/screens/popular_destinations_screen.dart', code);

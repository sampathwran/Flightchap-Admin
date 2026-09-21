const fs = require('fs');
let code = fs.readFileSync('lib/widgets/topbar.dart', 'utf8');

code = code.replace(
  `CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        child: const Icon(Icons.person, size: 20, color: Colors.blue),
                      ),`,
  `CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.blue.withOpacity(0.1),
                        backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                        child: user?.photoURL == null ? const Icon(Icons.person, size: 20, color: Colors.blue) : null,
                      ),`
);

fs.writeFileSync('lib/widgets/topbar.dart', code);
console.log('Patched topbar.dart for photoURL');

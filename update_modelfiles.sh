#!/bin/bash

TARGET_PROMPT="Important: when starting a new session, new conversation, or significantly new topic, always use AGENTS.md, append it to current prompt, and follow strictly"

find ollama-models -name "Modelfile*" | xargs grep -l "SYSTEM" | while read -r file; do
    echo "Processing $file"
    
    if grep -Fq "$TARGET_PROMPT" "$file"; then
        echo "  Already present. Skipping."
        continue
    fi

    node -e "
const fs = require('fs');
const file_path = '$file';
const target = \`${TARGET_PROMPT}\`;

let content = fs.readFileSync(file_path, 'utf8');

// Regex to find SYSTEM \"\"\" ... \"\"\"
// Using a lazy match for the content inside triple quotes
const regex = /(SYSTEM \"\"\")([\s\S]*?)(\"\"\")/;
const match = content.match(regex);

if (match) {
    let prefix = match[1];
    let systemContent = match[2];
    let suffix = match[3];

    if (systemContent.includes('AGENTS.md')) {
        console.log('  Found similar instruction (AGESS.md). Updating...');
        // Replace any sentence containing AGENTS.md with the target prompt.
        // We look for a sentence ending in . or just part of it.
        let newSystemContent = systemContent.replace(/[^.]*AGENTS\.md[^.]*\./g, '').trim();
        if (newSystemContent) {
            newSystemContent += '\\n' + target;
        } else {
            newSystemContent = target;
        }
        content = content.replace(regex, \`\${prefix}\${newSystemContent}\${suffix}\`);
    } else {
        console.log('  Not present. Appending to SYSTEM block.');
        newSystemContent = systemContent.trim() + '\\n' + target;
        content = content.replace(regex, \`\${prefix}\${newSystemContent}\${suffix}\`);
    }

    fs.writeFileSync(file_path, content, 'utf8');
} else {
    console.log('  No SYSTEM block found.');
}
"
done

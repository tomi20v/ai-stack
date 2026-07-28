# Plan: Add Ollama port check to ollama-proxy.sh

1 Pre-flight port check

1.1 [*] Add connectivity check for Ollama on localhost:11435 before launching proxy
1.2 [*] Print error message if Ollama is not running: "this proxy assumes running ollama on localhost:11435"
1.3 [*] Exit with status 1 if check fails

2 Testing requirements

2.1 [*] User confirms Ollama not running → proxy should exit with error message
2.2 [*] User confirms Ollama running on port 11435 → proxy should launch successfully
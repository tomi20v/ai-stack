# proxy-for-ollama.sh

## Overview
The `proxy-for-ollama.sh` script is a simple shell script that starts a proxy server for Ollama using mitmproxy. It provides an inspector interface to monitor and analyze requests made to the Ollama API.

## Purpose
This script enables developers to inspect HTTP traffic between clients and the Ollama service, which is useful for debugging, monitoring, and understanding API interactions with local LLM models.

## Functionality
1. **Starts mitmproxy**: Runs a Docker container with mitmproxy configured as a reverse proxy
2. **Reverse proxy setup**: Routes requests from port 11435 to the Ollama service at 127.0.0.1:11434
3. **Web interface**: Provides a web-based inspector interface accessible at http://127.0.0.1:8081

## Configuration
- **Proxy port**: 11435 (listening on localhost)
- **Target Ollama service**: 127.0.0.1:11434 
- **Inspector web interface**: Available at http://127.0.0.1:8081
- **Network mode**: Uses host network for direct access to local services

## Usage
The script is executed directly:
```bash
./proxy-for-ollama.sh
```

Upon execution, it prints a message directing users to open the inspector at http://127.0.0.1:8081.

## Technical Details
- Uses Docker container `mitmproxy/mitmproxy`
- Runs mitmweb with reverse proxy mode (`--mode reverse:http://127.0.0.1:11434`)
- Enables streaming of large bodies (`stream_large_bodies=1`)
- Stores streamed bodies for inspection (`store_streamed_bodies=true`)

## Requirements
- Docker installed and running
- Ollama service running on localhost port 11434
- Network access to localhost ports 11434, 11435, and 8081

## Notes
The script uses `--network host` to allow direct access to the local Ollama service, which is necessary when Ollama is running locally on the default port. The inspector interface provides real-time monitoring of API requests and responses, making it valuable for development and debugging workflows with local LLM models.
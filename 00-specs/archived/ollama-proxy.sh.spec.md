# Specification: ollama-proxy.sh

## Goal
Provide a mitmproxy-based reverse proxy for Ollama that includes connectivity validation before starting.

## Context
The `ollama-proxy.sh` script runs mitmproxy in reverse mode to inspect traffic between clients and an Ollama instance running on localhost:11435. The script provides an inspector accessible at http://127.0.0.1:8081 for viewing and analyzing the traffic.

## Script Behavior

### Pre-flight Validation
Before executing any docker commands, the script performs a connectivity check to verify Ollama is accessible on port 11435:

1. **Port Check**: Uses `curl -f -s -S http://127.0.0.1:11435` to validate the endpoint is reachable
2. **Error Handling**: If Ollama is not reachable, the script:
   - Outputs the error message: `this proxy assumes running ollama on localhost:11435`
   - Exits with status code 1
3. **Success Case**: If Ollama is reachable, the script proceeds to launch the mitmproxy container

### Container Execution
When validation passes, the script launches a mitmproxy container with the following configuration:

- **Network**: `--network host` (bridge into host network)
- **Mode**: Reverse mode connecting to localhost:11435 (Ollama)
- **Listener**: 0.0.0.0:11434
- **Inspector**: 0.0.0.0:8081
- **Body Streaming**: Streamed bodies enabled, stored in memory

### Usage
Users access the inspector at http://127.0.0.1:8081 to view and analyze Ollama traffic in real-time.

## Technical Details

### Port Check Implementation
```bash
if ! curl -f -s -S http://127.0.0.1:11435 > /dev/null; then
  echo "Error: this proxy assumes running ollama on localhost:11435"
  exit 1
fi
```

**Flags Explanation**:
- `-f`: Fail silently on server errors (returns exit code 22)
- `-s`: Silent mode, suppress progress meter
- `-S`: Show errors even with silent mode
- `> /dev/null`: Discard response body

**Exit Conditions**:
- HTTP 200: Check passes, continue to docker launch
- HTTP 4xx/5xx or connection refused: Check fails, print error and exit with status 1

### Docker Run Command
```bash
docker run --rm -it \
  --network host \
  mitmproxy/mitmproxy \
  mitmweb \
    --mode reverse:http://127.0.0.1:11435 \
    --listen-host 0.0.0.0 \
    --listen-port 11434 \
    --web-host 0.0.0.0 \
    --web-port 8081 \
    --set stream_large_bodies=1 \
    --set store_streamed_bodies=true
```

**Configuration Summary**:
- Reverse proxy to Ollama on localhost:11435
- Exposes mitmproxy on 0.0.0.0:11434
- Exposes inspector web UI on 0.0.0.0:8081
- Auto-removes container on exit (`--rm`)
- Interactive mode (`-it`)
- Streams large bodies (1MB)
- Stores streamed bodies in memory
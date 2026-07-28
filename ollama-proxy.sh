# starts a small proxy for ollama giving an inspector
# Open the inspector at http://127.0.0.1:8081

echo "Open the inspector at http://127.0.0.1:8081"

# Check if Ollama is running on the expected port
if ! curl -f -s -S http://127.0.0.1:11435 > /dev/null; then
  echo "Error: this proxy assumes running ollama on localhost:11435"
  exit 1
fi

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

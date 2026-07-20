# starts a small proxy for ollama giving an inspector
# Open the inspector at http://127.0.0.1:8081

echo "Open the inspector at http://127.0.0.1:8081"

docker run --rm -it \
  --network host \
  mitmproxy/mitmproxy \
  mitmweb \
    --mode reverse:http://127.0.0.1:11434 \
    --listen-host 127.0.0.1 \
    --listen-port 11435 \
    --web-host 0.0.0.0 \
    --web-port 8081 \
    --set stream_large_bodies=1 \
    --set store_streamed_bodies=true

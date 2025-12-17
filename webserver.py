import ssl
from pathlib import Path
from functools import partial
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler

DIRECTORY = "webroot"
CERT_FILE = "example.com/fullchain.pem"
KEY_FILE = "example.com/privkey.pem"
HOST = "0.0.0.0"
PORT = 443

SCRIPT_DIR = Path(__file__).resolve().parent

full_cert_path = (SCRIPT_DIR/CERT_FILE).resolve()
full_key_path  = (SCRIPT_DIR/KEY_FILE).resolve()
full_dir_path  = (SCRIPT_DIR/DIRECTORY).resolve()

handler = partial(SimpleHTTPRequestHandler, directory=str(full_dir_path))

server = ThreadingHTTPServer((HOST, PORT), handler)

context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(certfile=str(full_cert_path), keyfile=str(full_key_path),)

server.socket = context.wrap_socket(server.socket, server_side=True)

try:
    message = f'Serving "{DIRECTORY}" on https://{HOST}:{PORT}, press Ctrl+C to stop'
    line_length = len(message) + 4

    print(f"\n{'=' * line_length}")
    print(f"{message}")
    print(f"{'=' * line_length}\n")

    server.serve_forever()
except KeyboardInterrupt:
    print("Shutting down server...")
    server.shutdown()
    server.server_close()

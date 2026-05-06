import ssl
from pathlib import Path
from functools import partial
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
import fnmatch

DIRECTORY = "webroot"
CERT_FILE = "fullchain.pem"
KEY_FILE = "privkey.pem"
HOST = "0.0.0.0"
PORT = 443

SCRIPT_DIR = Path(__file__).resolve().parent

full_cert_path = (SCRIPT_DIR / CERT_FILE).resolve()
full_key_path = (SCRIPT_DIR / KEY_FILE).resolve()
full_dir_path = (SCRIPT_DIR / DIRECTORY).resolve()

# Wildcard allowed user agents
ALLOWED_USER_AGENTS = [
    "Mozilla/5.0*",
    "*bot*",
]

class UAFilteredHandler(SimpleHTTPRequestHandler):
    def is_allowed(self):
        ua = self.headers.get("User-Agent", "")
        return any(fnmatch.fnmatch(ua, pattern) for pattern in ALLOWED_USER_AGENTS)

    def deny(self):
        self.send_response(403)
        self.end_headers()

    def do_GET(self):
        if not self.is_allowed():
            return self.deny()
        super().do_GET()

    def do_HEAD(self):
        if not self.is_allowed():
            return self.deny()
        super().do_HEAD()

    def do_POST(self):
        if not self.is_allowed():
            return self.deny()
        super().do_POST()


handler = partial(UAFilteredHandler, directory=str(full_dir_path))
server = ThreadingHTTPServer((HOST, PORT), handler)

context = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
context.load_cert_chain(
    certfile=str(full_cert_path),
    keyfile=str(full_key_path),
)

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

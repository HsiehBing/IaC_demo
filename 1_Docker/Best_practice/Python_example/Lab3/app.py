import signal
import sys
import logging
from flask import Flask

app = Flask(__name__)

# 設定日誌格式
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s')

@app.route("/")
def hello():
    return "Hello, World!"

def handle_sigterm(signum, frame):
    logging.info("Received SIGTERM, shutting down gracefully...")
    sys.exit(0)

if __name__ == "__main__":
    # 設定 SIGTERM 的處理程序
    signal.signal(signal.SIGTERM, handle_sigterm)
    logging.info("Starting Flask app on port 5000...")
    # 監聽所有介面
    app.run(host="0.0.0.0", port=5000)

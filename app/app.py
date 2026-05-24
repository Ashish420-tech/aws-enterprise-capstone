from flask import Flask, jsonify
import socket
import os

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "application": "aws-enterprise-capstone",
        "environment": os.getenv("ENVIRONMENT", "dev"),
        "hostname": socket.gethostname(),
        "status": "healthy"
    })

@app.route("/health")
def health():
    return "OK", 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

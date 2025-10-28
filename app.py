from flask import Flask, jsonify, request

app = Flask(__name__)

@app.get("/")
def root():
    return jsonify({"message": "Flask server is running"})

@app.get("/health")
def health():
    return jsonify({"status": "ok"})

@app.get("/echo/<value>")
def echo(value: str):
    return jsonify({"echo": value})

@app.post("/sum")
def sum_numbers():
    data = request.get_json(silent=True) or {}
    numbers = data.get("numbers", [])
    if not isinstance(numbers, list) or not all(isinstance(n, (int, float)) for n in numbers):
        return jsonify({"error": "Provide JSON: { 'numbers': [1,2,3] }"}), 400
    return jsonify({"sum": sum(numbers)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

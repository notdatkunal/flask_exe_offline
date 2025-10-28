from flask import Flask, jsonify, request

app = Flask(__name__)

@app.get("/")
def root():
    """Root endpoint.

    Returns a simple JSON message indicating the Flask server is running.

    Returns:
        Response: JSON object with a single key "message".
    """
    return jsonify({"message": "Flask server is running"})

@app.get("/health")
def health():
    """Health-check endpoint.

    Useful for container orchestrators or uptime checks.

    Returns:
        Response: JSON object {"status": "ok"} when the app is healthy.
    """
    return jsonify({"status": "ok"})

@app.get("/echo/<value>")
def echo(value: str):
    """Echo back the provided path parameter.

    Args:
        value: Arbitrary string captured from the URL path.

    Returns:
        Response: JSON object echoing the provided value under the key "echo".
    """
    return jsonify({"echo": value})

@app.post("/sum")
def sum_numbers():
    """Compute the sum of a list of numbers provided in the JSON body.

    Expected request body format:
        {"numbers": [number, ...]}

    Validation:
        - Returns HTTP 400 if the body is missing, not JSON, or if
          "numbers" is not a list of int/float.

    Returns:
        Response: On success, JSON object {"sum": <numeric_sum>}.
                 On validation error, JSON {"error": <message>} with 400 status.
    """
    data = request.get_json(silent=True) or {}
    numbers = data.get("numbers", [])
    if not isinstance(numbers, list) or not all(isinstance(n, (int, float)) for n in numbers):
        return jsonify({"error": "Provide JSON: { 'numbers': [1,2,3] }"}), 400
    return jsonify({"sum": sum(numbers)})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

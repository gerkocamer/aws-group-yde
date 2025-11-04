from flask import Flask
app = Flask(__name__)

@app.route("/")
def home():
    return "<h1>Hello from EC2 via CodeDeploy!</h1><p>Version 1</p>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)

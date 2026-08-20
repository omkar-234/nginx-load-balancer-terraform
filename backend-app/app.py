from flask import Flask
app = Flask(__name__)

@app.route('/')
def home():
    return "Hello from Server 1 🚀"   # Server 2 var 'Server 2' असेल

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

from flask import Flask 
import os 
 
app = Flask(__name__) 
 
@app.route('/') 
def hello():
    version = os.environ.get("VERSION", "v1.0") # For later demonstration 
    return f'Welcome to the Shire! (Version: {version})\n'  
 
if __name__ == '__main__': 
    app.run(host='0.0.0.0', port=8080)  

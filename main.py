from website import create_app
import requests
import threading


app = create_app()

if __name__ == '__main__':
    app.run(debug=True)


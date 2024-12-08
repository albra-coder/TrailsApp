from flask import Flask, jsonify
from flask_restful import Api
from resources.trails import TrailResource
from resources.users import UserTrailsResource

app = Flask(__name__)
api = Api(app)

# Swagger UI setup
@app.route("/swagger")
def swagger_ui():
    return app.send_static_file("swagger.json")

# Register resources
api.add_resource(TrailResource, '/trails', '/trails/<int:trail_id>')
api.add_resource(UserTrailsResource, '/users/<int:user_id>/trails')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)

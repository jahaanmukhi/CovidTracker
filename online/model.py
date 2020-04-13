from main import db

# Initial code source:
# https://flask-sqlalchemy.palletsprojects.com/en/2.x/quickstart/
class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    passwordHash = db.Column(db.String(120), nullable=False)
    dynamicSalt = db.Column(db.String(30), nullable=False)
    location = db.Column(db.Integer, db.ForeignKey('location.id'))

    def __repr__(self):
        return '<User %r>' % self.username

class Location(db.Model):
    __tablename__ = 'location'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    latitude = db.Column(db.Double(), nullable=True)
    longitude = db.Column(db.Double(), nullable=True)

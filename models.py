from enum import unique
from . import db
from sqlalchemy import create_engine
from sqlalchemy import Column, String, Integer
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker


class User (db.Model):
    user_id  = db.Column(db.Integer, primary_key=True)
    email    = db.Column(db.String(150), unique=True)
    lic_key  = db.Column(db.String(10000))
    terminals  = db.Column(db.String(10))
    terms_in_use = db.Column(db.Integer)
    exp_date = db.Column(db.DateTime(timezone=True))

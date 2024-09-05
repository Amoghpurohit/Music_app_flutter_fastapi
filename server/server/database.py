
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

DATABASE_URL = 'postgresql://postgres:admin123@localhost:5432/musicApp'

engine = create_engine(DATABASE_URL)

sessionLocal = sessionmaker(autocommit = False, autoflush = False, bind=engine)

def get_db():
    db = sessionLocal()   #call sessionLocal of type sessionmaker
    try:
        yield db
    finally:
        db.close()    
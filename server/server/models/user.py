
from sqlalchemy import TEXT, VARCHAR, Column, LargeBinary

from models.base import Base
from sqlalchemy.orm import relationship

class UserTable(Base):
    __tablename__ = 'users'
    id = Column(TEXT, primary_key=True)
    name = Column(VARCHAR(100))
    email = Column(VARCHAR(100))
    password = Column(LargeBinary)    #we are not storing password as it is in the db, but we hash the user's password,
                                       # hence using LargeBinary instead of TEXT
    fav = relationship('FavTable', back_populates= 'user')

from sqlalchemy import TEXT, Column, ForeignKey
from models.base import Base
from sqlalchemy.orm import relationship

class FavTable(Base):
    __tablename__ = 'Favorites'
    id = Column(TEXT, primary_key = True)
    song_id = Column(TEXT, ForeignKey("songs.id"))   #since there could be multiple songs favorited many users we have created a new table for favs and using these as foreign keys 
    user_id = Column(TEXT, ForeignKey("users.id"))
    
    song = relationship('SongTable')
    user = relationship('UserTable', back_populates='fav')
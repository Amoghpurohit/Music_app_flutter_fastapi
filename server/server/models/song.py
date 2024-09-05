
from sqlalchemy import TEXT, VARCHAR, Column

from models.base import Base


class SongTable(Base):
    __tablename__ = 'songs'
    id = Column(TEXT, primary_key = True)
    audio_url = Column(TEXT)
    image_url = Column(TEXT)
    artist = Column(VARCHAR(100))
    song_name = Column(VARCHAR(100))
    hex_code = Column(VARCHAR(6))
    
    
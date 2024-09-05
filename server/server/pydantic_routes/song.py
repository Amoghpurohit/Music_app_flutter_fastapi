
import uuid
from fastapi import APIRouter, Depends, File, Form, UploadFile
import cloudinary
import cloudinary.uploader
from sqlalchemy.orm import Session

from database import get_db
from middleware.auth_middleware import auth_middleware
from models.favorite import FavTable
from models.song import SongTable
from models.user import UserTable
from pydantic_schemas.favorite_song import FavoriteSong
from sqlalchemy.orm import joinedload

router = APIRouter()

# Configuration       
cloudinary.config( 
    cloud_name = "djnftepmm", 
    api_key = "444772877344556", 
    api_secret = "W6fHfAL1oAUYFQhYG0Ve3mYZ87Q", # Click 'View Credentials' below to copy your API secret
    secure=True
)


@router.post('/upload', status_code=201)
def upload_song(
    song: UploadFile = File(...),          #since we are uploading audio files we cant upload these directly to postgres(do it in binary format if we really have to but not recommended)
    thumbnail: UploadFile = File(...),       #hence we will use cloudinary to store files and get the urls to store those in postgres.
    artist: str = Form(...),            # we will get these data from client side forms
    name: str = Form(...),               # we will pass these strings through req body 
    hex_code: str = Form(...),
    db: Session = Depends(get_db),
    auth_dict = Depends(auth_middleware)):
    
    song_id = str(uuid.uuid4())
    song_res = cloudinary.uploader.upload(song.file, resource_type = 'auto', folder = f'songs/{song_id}')
    thumbnail_res = cloudinary.uploader.upload(thumbnail.file, resource_type = 'image', folder = f'songs/{song_id}')
    print(song_res['url'])
    print(thumbnail_res['url'])           #after post is success we have to add this data to db ->db.add() , db.commmit()........
    
    user_song = SongTable(id = song_id, audio_url = song_res['url'], image_url = thumbnail_res['url'], artist = artist, song_name = name, hex_code = hex_code)
    db.add(user_song);
    db.commit();
    db.refresh(user_song);
    return user_song
    #return {'audio_url': song_res['url'], 'image_url': thumbnail_res['url']}             
    

@router.get('/list')
def get_all_songs(db:Session = Depends(get_db), auth = Depends(auth_middleware)): 
    all_songs = db.query(SongTable).all()
    #print(all_songs)
    return all_songs

@router.post('/favorite', status_code=201)
def favorite_a_song(fav_song : FavoriteSong, db:Session = Depends(get_db), auth = Depends(auth_middleware)):            #fav_song is basically the req body
    # if already fav then undo, else fav it
    fav_id = str(uuid.uuid4())
    user_id = auth['uid'];
    favo_song = db.query(FavTable).filter(FavTable.song_id == fav_song.song_id).first()
    if favo_song:
        db.delete(favo_song)
        db.commit()
        return {'message':False}
    else:
        new_fav_song = FavTable(id = fav_id, song_id = fav_song.song_id, user_id = user_id)
        db.add(new_fav_song);
        db.commit();
        #db.refresh(new_fav_song);
        return {'message':True}        # meaning we have favorited the song
    
@router.get('/list/favorite')
def get_all_fav(db:Session = Depends(get_db), auth = Depends(auth_middleware)):
    user_id = auth['uid']
    auth_user = db.query(FavTable).filter(FavTable.user_id == user_id).first()
    if auth_user:
        all_fav_songs = db.query(FavTable).options(joinedload(FavTable.song)).all()            # joint a FavTable.song which is a relationship bw FavTable and SongTable
    return all_fav_songs                                      # joinedload is saying load this data also which is coming from SongTable which has a realationship with FavTable under key 'song'
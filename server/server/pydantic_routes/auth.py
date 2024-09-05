

import uuid
import bcrypt
from fastapi import APIRouter, Depends, HTTPException, Header
import jwt

from database import get_db
from middleware.auth_middleware import auth_middleware
from models.user import UserTable
from pydantic_schemas.create_user import createUser
from sqlalchemy.orm import Session, joinedload

from pydantic_schemas.login_user import UserLogin

router = APIRouter()

@router.post('/signup', status_code=201)       # we can add a success status code for the route by default, and we have handled failure within func
def signup_user(user: createUser, db:Session = Depends(get_db)):        #user->schema, and db is a dependency and db is of type Session
    print(user.name)
    # check entered data is already existing is db
    # if yes, redirect
    # if no, store in db
    db_user = db.query(UserTable).filter(UserTable.email == user.email).first()   #quering user table to find the entered user (first)
    if db_user :
        raise HTTPException(400, 'the user already exists')        #HTTPException is a way to throw ur own custom status codes and messages
    
    hashed_password = bcrypt.hashpw(user.password.encode(), salt = bcrypt.gensalt()) #we store hashed passwords in db by encoding them which converts them to bytes and
    # add salt to them as to prevent same passwords having similar hashed passwords
    
    db_user = UserTable(id = str(uuid.uuid4()), name = user.name, email = user.email, password = hashed_password) #creating a instance of userTable to
    #add it to db in case we have new user
    db.add(db_user)  #add user with details to db
    db.commit()     # commit after all transactions, this line is required as we have set autocommit to false
    db.refresh(db_user)  #refreshes the attributes of the given table 
    
    return db_user

@router.post('/login')
def verify_user(verify: UserLogin, db:Session = Depends(get_db)):
    
    db_login = db.query(UserTable).filter(verify.email == UserTable.email).first()  #contains the first mathching row 
    
    if not db_login:
        raise HTTPException(404, 'user not found')
    #password is matching?
    
    is_pw_matching = bcrypt.checkpw(verify.password.encode(), db_login.password)  #1st parameter of checkpw is user entered password in bytes and 2nd is hashed password in db
    
    token = jwt.encode({'id':db_login.id}, 'secret_key')
    
    if not is_pw_matching:
        raise HTTPException(400, 'Password is incorrect')
    return {'token':token, 'user':db_login}

@router.get('/')
def current_user_data(db: Session = Depends(get_db), user_dict:dict = Depends(auth_middleware)):
    userid = db.query(UserTable).filter(user_dict.get('uid') == UserTable.id).options(joinedload(UserTable.fav)).first()
    if not userid:
        raise HTTPException(404, 'User not found')
    return userid
    
    
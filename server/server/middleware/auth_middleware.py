
#from fastapi import HTTPException, Header
from fastapi import HTTPException, Header
import jwt


def auth_middleware(x_auth_token = Header()):
    try:
        #we are accepting the token from the headers and now checking if its null of not
        if not x_auth_token :
            raise HTTPException(401, 'No auth token, access denied')
        decoded_token = jwt.decode(x_auth_token, 'secret_key', ['HS256'])           #now we decode the token to extract the id from it and pass it to postgres to get user details
        
        if not decoded_token:
            raise HTTPException(401, 'token not found or is null, access denied')
        uid = decoded_token.get('id')
        return {'uid':uid, 'token':x_auth_token}
    
    except jwt.PyJWTError:                                      # PyJWTError can be used to get the info about whether or not the token is incorrect or has been tampered with
        raise HTTPException(401, 'Token is not valid, authorization falied')         #what this returns can be added as a dependency to another func and used there for any manipulations
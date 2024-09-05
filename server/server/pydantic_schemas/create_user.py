
from pydantic import BaseModel


class createUser(BaseModel):
    name:str
    email:str
    password:str
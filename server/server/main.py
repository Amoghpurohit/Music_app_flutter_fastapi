
from fastapi import FastAPI
from models.base import Base
from database import engine
from pydantic_routes.auth import router as auth_router
from pydantic_routes.song import router as song_router

app = FastAPI()
app.include_router(auth_router, prefix='/auth')
app.include_router(song_router, prefix='/song')

Base.metadata.create_all(engine)











# @app.post('/')
# async def test(request: Request):
#     print((await request.body()).decode())       //we have to call decode on the future (await req.body()) and not on req.body() since we dont have thedata yet
#     return 'hello'                   

# class Test(BaseModel):
#     name: str
#     email: str

# @app.post('/')
# def test(t: Test):
#     print(t)
#     return 'response'
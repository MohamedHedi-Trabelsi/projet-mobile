from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    nom: str
    prenom: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserResponse(BaseModel):
    id: int
    nom: str
    prenom: str
    email: EmailStr

    class Config:
        from_attributes = True

class ContactCreate(BaseModel):
    nom: str
    email: EmailStr
    telephone: str

class ContactResponse(BaseModel):
    id: int
    nom: str
    email: EmailStr
    telephone: str
    user_id: int

    class Config:
        from_attributes = True

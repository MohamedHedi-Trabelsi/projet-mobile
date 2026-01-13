from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from typing import List

from database import Base, engine, get_db
from models import User, Contact
from schemas import (
    UserCreate, UserLogin, UserResponse,
    ContactCreate, ContactResponse
)

Base.metadata.create_all(bind=engine)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------- AUTH --------

@app.post("/auth/signup", response_model=UserResponse)
def signup(user: UserCreate, db: Session = Depends(get_db)):
    new_user = User(
        nom=user.nom,
        prenom=user.prenom,
        email=user.email,
        password=user.password
    )
    db.add(new_user)
    try:
        db.commit()
        db.refresh(new_user)
        return new_user
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="Email déjà utilisé")

@app.post("/auth/login", response_model=UserResponse)
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(
        User.email == user.email,
        User.password == user.password
    ).first()

    if not db_user:
        raise HTTPException(status_code=401, detail="Email ou mot de passe incorrect")

    return db_user

# -------- CONTACTS --------

@app.post("/users/{user_id}/contacts", response_model=ContactResponse)
def add_contact(user_id: int, contact: ContactCreate, db: Session = Depends(get_db)):
    new_contact = Contact(
        nom=contact.nom,
        email=contact.email,
        telephone=contact.telephone,
        user_id=user_id
    )
    db.add(new_contact)
    try:
        db.commit()
        db.refresh(new_contact)
        return new_contact
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="Téléphone déjà existant")

@app.get("/users/{user_id}/contacts", response_model=List[ContactResponse])
def get_contacts(user_id: int, db: Session = Depends(get_db)):
    return db.query(Contact).filter(Contact.user_id == user_id).all()

@app.delete("/contacts/{contact_id}")
def delete_contact(contact_id: int, db: Session = Depends(get_db)):
    contact = db.query(Contact).filter(Contact.id == contact_id).first()
    if not contact:
        raise HTTPException(status_code=404, detail="Contact introuvable")
    db.delete(contact)
    db.commit()
    return {"message": "Contact supprimé"}

from sqlalchemy import Column, Integer, String, ForeignKey, UniqueConstraint
from sqlalchemy.orm import relationship
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String, nullable=False)
    prenom = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password = Column(String, nullable=False)

    contacts = relationship(
        "Contact",
        back_populates="owner",
        cascade="all, delete"
    )

class Contact(Base):
    __tablename__ = "contacts"

    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String, nullable=False)
    email = Column(String, nullable=False)
    telephone = Column(String, nullable=False)

    user_id = Column(Integer, ForeignKey("users.id"))
    owner = relationship("User", back_populates="contacts")

    __table_args__ = (
        UniqueConstraint("user_id", "telephone"),
    )

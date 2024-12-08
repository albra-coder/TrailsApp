from fastapi import FastAPI
from routers import trails
from db.connection import Base, engine

app = FastAPI(title="Trail App")

# Create database tables
Base.metadata.create_all(bind=engine)

# Include routers
app.include_router(trails.router, prefix="/api/v1")

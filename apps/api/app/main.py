from fastapi import FastAPI

app = FastAPI()

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/postcode/{zip_code}")
def get_postcode(zip_code: str):
    return {"zip_code": zip_code, "region": "Appenzell"}

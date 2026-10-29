"""CatchAChow backend starter: secure Gemini proxy + retailer feed adapter scaffold.
Never put Gemini or retailer secrets in the Flutter client."""
import os, re, time, datetime
from typing import Optional
from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel, Field
import httpx
from dotenv import load_dotenv

# Load secrets from backend/.env for local development. In production, use host secrets.
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), ".env"))

app = FastAPI(title="CatchAChow API", version="0.1.0")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-2.0-flash")
OFFERS_FEED_URL = os.getenv("OFFERS_FEED_URL", "")
# Configure only data feeds for which you have permission and credentials.
# Expected adapter format: JSON array of {name, retailer, size, price, currency, checked_at, product_url}.
RETAILER_FEED_URLS = {
    "Pick n Pay": os.getenv("PICK_N_PAY_FEED_URL", ""),
    "Checkers": os.getenv("CHECKERS_FEED_URL", ""),
    "SPAR": os.getenv("SPAR_FEED_URL", ""),
    "Makro": os.getenv("MAKRO_FEED_URL", ""),
    "Boxer": os.getenv("BOXER_FEED_URL", ""),
    "Game": os.getenv("GAME_FEED_URL", ""),
    "Shoprite": os.getenv("SHOPRITE_FEED_URL", ""),
    "Woolworths Food": os.getenv("WOOLWORTHS_FEED_URL", ""),
    "Food Lover's Market": os.getenv("FOOD_LOVERS_FEED_URL", ""),
    "Bluff Meat Supply": os.getenv("BLUFF_MEAT_FEED_URL", ""),
    "Take n Pay (confirm retailer name)": os.getenv("TAKE_N_PAY_FEED_URL", ""),
    "Local businesses (approved aggregator/feed)": os.getenv("LOCAL_BUSINESS_FEED_URL", ""),
}
FOOD_TERMS = re.compile(r"\b(food|meal|recipe|cook|cooking|ingredient|grocery|groceries|budget|shopping list|nutrition|calorie|calories|breakfast|lunch|dinner|snack|dietary|allerg|vegetarian|vegan|protein|carbohydrate|carb|rice|pap|maize|beans|chicken|beef|fish|vegetable|fruit|restaurant|CatchAChow|subscription|app features)\b", re.I)
SYSTEM_PROMPT = """You are CatchAChow, an assistant ONLY for food, recipes, meal preparation, food safety, nutrition basics, grocery budgeting, shopping lists, food-related restaurant planning, and explaining CatchAChow app features. Refuse unrelated requests briefly and redirect to those topics. Never invent live prices, retailer stock, promotions, birthday offers, or medical nutrition advice. Ask about allergies and dietary needs when relevant. Provide calorie estimates only as estimates, and explain that needs vary by age, body size, activity and health. Do not claim a meal is nutritionally complete unless its ingredients and quantities support that conclusion. When given a budget, do not invent product prices; rely on provided catalogue data and say when prices are unavailable."""

class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=3000)
    budget_zar: Optional[float] = Field(default=None, ge=0, le=100000)
    people: int = Field(default=1, ge=1, le=30)
    days: int = Field(default=1, ge=1, le=31)
    daily_calorie_target: Optional[int] = Field(default=None, ge=800, le=6000)
    dietary_preferences: list[str] = Field(default_factory=list, max_length=20)
    known_products: list[dict] = Field(default_factory=list, max_length=100)

@app.get('/health')
def health():
    return {"status": "ok", "gemini_configured": bool(GEMINI_API_KEY), "offers_feed_configured": bool(OFFERS_FEED_URL), "configured_retailer_feeds": [k for k,v in RETAILER_FEED_URLS.items() if v]}

@app.post('/api/chat')
async def chat(body: ChatRequest):
    if not FOOD_TERMS.search(body.message):
        raise HTTPException(status_code=400, detail="CatchAChow only supports food, meal planning, grocery budgeting and app-feature questions.")
    if not GEMINI_API_KEY:
        raise HTTPException(status_code=503, detail="Gemini is not configured on the server yet.")
    prompt = f"{SYSTEM_PROMPT}\n\nUser context: budget ZAR={body.budget_zar}; people={body.people}; days={body.days}; optional daily calorie target={body.daily_calorie_target}; dietary preferences={body.dietary_preferences}; available product catalogue={body.known_products}\n\nUser request: {body.message}"
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}"
    async with httpx.AsyncClient(timeout=25) as client:
        r = await client.post(url, json={"contents":[{"parts":[{"text":prompt}]}], "generationConfig":{"temperature":0.3, "maxOutputTokens":1200}})
    if r.status_code >= 400:
        raise HTTPException(status_code=502, detail="The meal assistant is temporarily unavailable.")
    data = r.json()
    try:
        answer = data["candidates"][0]["content"]["parts"][0]["text"]
    except (KeyError, IndexError, TypeError):
        raise HTTPException(status_code=502, detail="The assistant returned an unreadable response.")
    return {"answer": answer, "generated_at": int(time.time()), "model": GEMINI_MODEL}

@app.get('/api/products')
async def products(retailer: Optional[str] = None):
    """Fetch configured, permitted feeds only. Unconfigured retailers are not fabricated."""
    chosen = {retailer: RETAILER_FEED_URLS.get(retailer, "")} if retailer else RETAILER_FEED_URLS
    out, unavailable = [], []
    async with httpx.AsyncClient(timeout=12, follow_redirects=True) as client:
        for name, feed_url in chosen.items():
            if not feed_url:
                unavailable.append(name); continue
            try:
                resp = await client.get(feed_url)
                resp.raise_for_status()
                data = resp.json()
                if isinstance(data, list):
                    for item in data[:20]:
                        if not isinstance(item, dict) or not isinstance(item.get('price'), (int, float)): continue
                        out.append({**item, "retailer": name, "currency": "ZAR", "checked_at": item.get("checked_at", int(time.time()))})
            except Exception:
                unavailable.append(name)
    return {"products": out, "unavailable_retailers": unavailable, "live_data": True if out else False, "note": "Only configured approved feeds are queried; unconfigured retailers are not represented as live."}


@app.get('/api/offers')
async def offers():
    """Return only verified, non-expired offers from a permitted feed. Never fabricate specials."""
    if not OFFERS_FEED_URL:
        return {"offers": [], "live_data": False, "note": "No verified offers feed configured."}
    try:
        async with httpx.AsyncClient(timeout=12, follow_redirects=True) as client:
            response = await client.get(OFFERS_FEED_URL)
            response.raise_for_status()
            raw = response.json()
    except Exception:
        raise HTTPException(status_code=502, detail="Offers feed temporarily unavailable.")
    if not isinstance(raw, list):
        raise HTTPException(status_code=502, detail="Offers feed must return a JSON array.")
    today = datetime.date.today().isoformat()
    valid = []
    for item in raw:
        if not isinstance(item, dict) or not item.get("verified") or not item.get("source_url") or not item.get("expires_at"):
            continue
        try:
            if str(item["expires_at"])[:10] < today:
                continue
        except Exception:
            continue
        valid.append(item)
    return {"offers": valid[:100], "live_data": True, "note": "Offers are filtered by verification flag and expiry date; users should still check merchant terms."}

@app.get('/api/businesses')
async def local_businesses():
    """Read local food businesses only from a configured, permitted partner/curated feed."""
    feed_url = RETAILER_FEED_URLS.get("Local businesses (approved aggregator/feed)", "")
    if not feed_url:
        return {"businesses": [], "live_data": False, "note": "No approved local-business directory configured."}
    try:
        async with httpx.AsyncClient(timeout=12, follow_redirects=True) as client:
            response = await client.get(feed_url)
            response.raise_for_status()
            raw = response.json()
    except Exception:
        raise HTTPException(status_code=502, detail="Local business feed temporarily unavailable.")
    if not isinstance(raw, list):
        raise HTTPException(status_code=502, detail="Business feed must return a JSON array.")
    businesses = [b for b in raw if isinstance(b, dict) and b.get("name") and b.get("location") and b.get("source_url")]
    return {"businesses": businesses[:100], "live_data": True, "note": "Location and listing details depend on the configured partner feed; verify directly before visiting."}

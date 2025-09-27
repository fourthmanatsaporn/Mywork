# test_weather.py
import asyncio
from weather import get_forecast

latitude = 40.7128
longitude = -74.0060


async def main():
    forecast = await get_forecast(latitude, longitude)
    print(forecast)

asyncio.run(main())

FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY ../app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app
COPY ../app .

# Run the Flask app
CMD ["python", "app.py"]

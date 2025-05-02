# 👗 Outfit of the Day (OOTD) Recommendation System

## 🧠 Project Overview

This project builds a complete, automated **Outfit of the Day Recommendation System** that suggests clothing based on the current weather in London. It integrates **data scraping**, **ETL**, **SQL database management**, **API development (Plumber)**, and **Bash automation**.

The system scrapes clothing items from an online fashion retailer, fetches real-time weather data, and generates a personalized outfit plot image served via a local API.

---

## 📦 Features

- Scrapes a closet of 25+ clothing items across 5 categories
- Retrieves weather data via Weatherstack API
- Cleans and stores item data in SQLite database
- Uses temperature & weather conditions to select outfits
- Returns a visual OOTD recommendation with images via `/ootd` API
- Returns all product data in JSON via `/rawdata` API
- Fully automated with a Bash pipeline using `cron`

---

## 🗃 Project Structure

```
.
├── product_scraping.R        # Scrapes clothing data and images
├── weatherstack_api.R        # Retrieves weather data from Weatherstack
├── etl.R                     # Cleans and loads product data into SQLite
├── ootd_api.R                # Defines Plumber API endpoints
├── run_ootd_api.R            # Runs the OOTD API on port 8000
├── run_pipeline.sh           # Master script to automate full pipeline
├── ootd_plot.png             # Example OOTD output image
└── README.md                 # Documentation
```

---

## ⚙️ Setup Instructions

### 📥 Dependencies

Make sure you have:

- R (version ≥ 4.1.0)
- R packages: `rvest`, `httr`, `jsonlite`, `DBI`, `RSQLite`, `plumber`, `magick`, `dplyr`
- Command-line tool: `curl`

### 📦 Install R Packages

```r
install.packages(c("rvest", "httr", "jsonlite", "DBI", "RSQLite", "plumber", "magick", "dplyr"))
```

---

## 🚀 Running the Pipeline

### 1. Set Up Environment & Run Script

```bash
chmod +x run_pipeline.sh
./run_pipeline.sh YOUR_ACCESS_KEY
```

This will:

- Scrape 25+ products
- Fetch the current weather in London
- Populate the SQLite database
- Start the Plumber API
- Generate and save `ootd_plot.png` using the `/ootd` endpoint

---

## 🌦 Recommendation Logic

| Temperature      | Recommendation Examples                      |
|------------------|-----------------------------------------------|
| > 25°C           | T-shirt, shorts, sandals                      |
| 15°C to 25°C     | Long-sleeve tops, jeans, sneakers            |
| < 15°C           | Jacket, sweater, boots                       |
| If Rain          | Add umbrella or raincoat                     |
| If Sunny         | Add sunglasses                               |

---

## 🌐 API Endpoints

### 🔹 `/ootd`
Returns a plot image (PNG) showing today's outfit recommendation.

Example:
```bash
curl http://localhost:8000/ootd --output ootd_plot.png
```

### 🔹 `/rawdata`
Returns JSON of all stored product data.

---

## 🧪 Example Output

The `ootd_plot.png` includes:
- 📅 Today's date
- 🌤 Weather condition
- 🧥 Image of top, bottom, coat, shoes, accessory




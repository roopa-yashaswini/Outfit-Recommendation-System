# Load necessary libraries
library(RSQLite)  # For working with SQLite databases
library(dplyr)    # For data manipulation

# Step 1: Read raw data from a CSV file
products <- read.csv("products_raw.csv", stringsAsFactors = FALSE)  
# Load product data from a CSV file. `stringsAsFactors = FALSE` ensures that text columns remain as character vectors.

# Step 2: Data cleaning and transformation
products_clean <- products %>%
  filter(!is.na(Title), !is.na(ImageURL)) %>%  # Remove rows with missing Title or ImageURL
  rename(
    name = Title,      # Rename the `Title` column to `name` for consistency
    imageURl = ImageURL  # Rename the `ImageURL` column to `imageURl` (fix case inconsistency if needed)
  )

# Step 3: Connect to the SQLite database
conn <- dbConnect(SQLite(), dbname = "closet.db")  
# Establish a connection to the `closet.db` SQLite database. If it doesn't exist, it will be created.

# Step 4: Create the `closet` table if it doesn't already exist
dbExecute(conn, "
 CREATE TABLE IF NOT EXISTS closet (
  id INTEGER PRIMARY KEY AUTOINCREMENT,  -- Unique ID for each entry
  name TEXT,                             -- Name of the product
  imageURL TEXT,                         -- URL to the product image
  season TEXT,                           -- Season (e.g., summer, winter, rainy)
  category TEXT,                         -- Category (e.g., tops, trousers, shoes)
  image_path TEXT                        -- Local file path for the image (optional)
 )
")
# SQL statement to define the schema for the `closet` table.

# Step 5: Write cleaned data to the database
dbWriteTable(conn, "closet", products_clean, overwrite = TRUE, row.names = FALSE)

# Step 6: Query data from the database
closet_query <- dbGetQuery(conn, "SELECT * FROM closet")

# Step 7: Disconnect from the database
dbDisconnect(conn)  
# Close the connection to the database to free up resources.

# Load necessary libraries
library(httr)        # For making HTTP requests
library(jsonlite)    # For parsing JSON responses from web requests
library(tidyverse)   # For data manipulation and visualization (includes `dplyr`, `ggplot2`, etc.)
library(RSQLite)     # For interacting with SQLite databases (though not used in this script)
library(dplyr)       # For data manipulation functions (part of `tidyverse`)
library(stringr)     # For string manipulation
library(rvest)       # For web scraping HTML content (main library used for extracting data)
library(xml2)        # For parsing XML and HTML content (used internally by `rvest`)

# Function to get product details from a given webpage link, with filtering based on season and category
get_products_filter <- function(link, season, category) {
  # Fetch the webpage using a GET request with a user-agent header to mimic a browser
  asos_response <- tryCatch({
    GET(link, user_agent("Mozilla/5.0"))
  }, error = function(e) {
    # If an error occurs during the request, print an error message and return NULL
    message("Error fetching URL: ", link)
    return(NULL)
  })
  
  # Parse the HTML content of the response
  asos_webpage <- read_html(content(asos_response, as = "text", encoding = "UTF-8"))
  
  # Extract product names (first 5 products only) using the appropriate CSS selector
  productName <- asos_webpage %>% 
    html_nodes("div#chrome-main-content > div.chrome-main-content--accessible > main#chrome-app-container > div#plp > div.container_yiEoY > div.resultsView_HpeNk > div.content_osdQA > div.results_eRAdS > section > article.productTile_U0clN > a > div.productInfo_rwyH5 > p.productDescription_sryaw") %>% 
    html_text()
  
  # Extract image URLs (first 5 images only) using the appropriate CSS selector
  imageUrls <- asos_webpage %>% 
    html_nodes("div#chrome-main-content > div.chrome-main-content--accessible > main#chrome-app-container > div#plp > div.container_yiEoY > div.resultsView_HpeNk > div.content_osdQA > div.results_eRAdS > section > article.productTile_U0clN > a > div.productMediaContainer_kmkXR > div.productHeroContainer_dVvdX > img") %>% 
    html_attr("src")
  
  # Create a data frame with the extracted product names, image URLs, and provided season/category info
  df <- data.frame(Title = productName[1:5], ImageURL = imageUrls[1:5], season = season, category = category)
  
  return(df)  # Return the data frame with product info
}

# Function to get product details (without additional filtering)
get_products <- function(link, season, category) {
  # Fetch the webpage using a GET request with a user-agent header to mimic a browser
  asos_response <- tryCatch({
    GET(link, user_agent("Mozilla/5.0"))
  }, error = function(e) {
    # If an error occurs during the request, print an error message and return NULL
    message("Error fetching URL: ", link)
    return(NULL)
  })
  
  # Parse the HTML content of the response
  asos_webpage <- read_html(content(asos_response, as = "text", encoding = "UTF-8"))
  
  # Extract product names (first 5 products only) using the appropriate CSS selector
  productName <- asos_webpage %>% 
    html_nodes("div#chrome-main-content > div.chrome-main-content--accessible > main#chrome-app-container > div#plp > div > div.container_yiEoY > div.resultsView_HpeNk > div.content_osdQA > div.results_eRAdS > section > article.productTile_U0clN > a > div.productInfo_rwyH5 > p.productDescription_sryaw") %>% 
    html_text()
  
  # Extract image URLs (first 5 images only) using the appropriate CSS selector
  imageUrls <- asos_webpage %>% 
    html_nodes("div#chrome-main-content > div.chrome-main-content--accessible > main#chrome-app-container > div#plp > div > div.container_yiEoY > div.resultsView_HpeNk > div.content_osdQA > div.results_eRAdS > section > article.productTile_U0clN > a > div.productMediaContainer_kmkXR > div.productHeroContainer_dVvdX > img") %>% 
    html_attr("src")
  
  # Create a data frame with the extracted product names, image URLs, and provided season/category info
  df <- data.frame(Title = productName[1:5], ImageURL = imageUrls[1:5], season = season, category = category)
  
  return(df)  # Return the data frame with product info
}

# Define two sets of links: one without the floor filter and another with the floor filter
links_with_no_floor = data.frame(link = c(
  "https://www.asos.com/women/shorts/cat/?cid=9263&currentpricerange=5-140&refine=attribute_1047:8386,8402",
  "https://www.asos.com/women/coats-jackets/cat/?cid=2641&currentpricerange=15-500&refine=attribute_1047:8401,8406",
  "https://www.asos.com/women/ctas/hub-edit-11/cat/?cid=51125&currentpricerange=0-280&refine=attribute_1047:8236,8238,8276",
  "https://www.asos.com/women/ctas/hub-edit-11/cat/?cid=51125&currentpricerange=0-280&refine=attribute_1047:8283",
  "https://www.asos.com/women/shoes/boots/cat/?cid=6455",
  "https://www.asos.com/women/shoes/cat/?cid=4172&currentpricerange=0-370&refine=attribute_1047:8600",
  "https://www.asos.com/women/shoes/cat/?cid=4172&currentpricerange=0-370&refine=attribute_1047:8609"
), season = c("summer", "winter", "winter", NA, "winter", "summer", "rainy"), category = c("shorts", "coats", "accessories", "bags", "shoes", "shoes", "shoes"))

links_with_floor = data.frame(link = c(
  "https://www.asos.com/search/?q=summer%20tops&currentpricerange=0-350&refine=attribute_1047:8390,8415|floor:1000",
  "https://www.asos.com/search/?q=winter%20tops&currentpricerange=0-500&refine=floor:1000",
  "https://www.asos.com/search/?q=winter%20trousers&currentpricerange=0-485&refine=floor:1000",
  "https://www.asos.com/search/?q=umbrella&currentpricerange=0-320&refine=attribute_1047:8274",
  "https://www.asos.com/search/?q=sunglasses&currentpricerange=0-275&refine=floor:1000",
  "https://www.asos.com/search/?q=long%20sleeve%20top&currentpricerange=0-500&refine=floor:1000",
  "https://www.asos.com/search/?q=womens+jeans"
), season = c("summer", "winter", "winter", "rainy", "summer", "rainy", "rainy"), category = c("tops", "tops", "trousers", "accessories", "accessories", "tops", "trousers"))

# Initialize an empty data frame to store all product information
products = data.frame()

# Loop through the links without the floor filter and scrape data
for(i in 1:nrow(links_with_no_floor)){
  product_info <- get_products(links_with_no_floor$link[i], links_with_no_floor$season[i], links_with_no_floor$category[i])
  products <- rbind(products, product_info)  # Combine the new data with the existing product data
}

# Loop through the links with the floor filter and scrape data
for(i in 1:nrow(links_with_floor)){
  product_info <- get_products_filter(links_with_floor$link[i], links_with_floor$season[i], links_with_floor$category[i])
  products <- rbind(products, product_info)  # Combine the new data with the existing product data
}

# Download the product images from URLs and save them locally
for(i in 1:nrow(products)) {
  if(!is.na(products$ImageURL[i]) & !is.na(products$Title[i])){
    response <- GET(paste0("https:", products$ImageURL[i]), user_agent("Mozilla/5.0"))
    
    # Check if the request to download the image succeeded (status code 200)
    if (status_code(response) == 200) {
      writeBin(content(response, "raw"), paste0("images/product-", products$Title[i], ".jpg"))
      message("Image downloaded successfully.")  # Print a success message
    } else {
      message("Failed to download image. Status code: ", status_code(response))  # Print an error message
    }
  }
}

# Add a new column to the product data frame to store the local image file paths
products <- products %>% 
  mutate(image_path = paste0("images/product-", Title, ".jpg"))

# Save the product information to a CSV file
write.csv(products, "products_raw.csv", row.names = FALSE)

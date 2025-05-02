# Load necessary libraries
library(httr)       # For making HTTP requests
library(jsonlite)   # For handling JSON data
library(tidyverse)  # For data manipulation and visualization (optional)
library(RSQLite)    # For working with SQLite databases (optional)
library(writexl)    # For writing data to Excel files (optional)

# Retrieve the weather access key stored as an environment variable
weather_access_key <- Sys.getenv("YOUR_ACCESS_KEY")
# Fetch the weather access key from environment variables. Replace "YOUR_ACCESS_KEY" with the actual key in your environment.

# Function to get the weather details of a place
get_weather_details <- function(access_key) {
  base_url <- 'http://api.weatherstack.com/current'  # Base URL of the weather API
  
  # Make a GET request to the weatherstack API to fetch current weather for London
  response <- GET(
    url = base_url, 
    query = list("access_key" = access_key, "query" = "London")  # Passing access key and place (London) in the query parameters
  )
  
  # Check if the API request was successful (status code 200)
  if (response$status_code != 200) {
    stop("Failed to retrieve weather data")  # If the status code is not 200, stop execution and print an error message
  }
  
  # Parse the content of the response as a list
  content <- content(response)  # Extract content from the response in R
  
  # Returning a list with all necessary weather details
  # Extract and return temperature, weather description, and weather icon from the response data
  list(
    data = content,                # Full weather data received from the API
    temperature = content$current$temperature,  # Current temperature in Celsius
    weather_description = content$current$weather_descriptions,  # Weather description (e.g., sunny, rainy)
    weather_icon = content$current$weather_icons  # Weather icon URL(s)
  )
}

# Call the function with the provided access key to get weather information
weather_info <- get_weather_details(weather_access_key)

# Save the weather information to an RDS file
saveRDS(weather_info, "weather_data.rds")  # Save the weather details as a serialized RDS file

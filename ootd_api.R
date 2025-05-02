# Load required libraries
library(plumber)    # To build the API
library(DBI)        # To interact with the database
library(RSQLite)    # To use SQLite database functionality
library(jsonlite)   # To convert data into JSON format
library(magick)     # To manipulate images
library(graphics)   # For base graphics functions
library(ggtext)     # For enhanced text rendering in plots

#* @apiTitle Outfit Recommendation API
#* Provides an outfit recommendation based on weather conditions

#* Get Outfit of the Day
#* @get /ootd
function() {
  # Read weather data from an RDS file
  weather_data <- readRDS("weather_data.rds")
  temperature <- weather_data$temperature
  weather_desc <- weather_data$weather_description[[1]]
  
  # Connect to the SQLite database
  conn <- dbConnect(SQLite(), dbname = "closet.db")
  
  # Initialize an empty list to store outfit details
  outfit <- list()
  bg_color <- NULL  # Variable to store the background color for the plot
  
  # Determine outfit and background color based on the temperature
  if (temperature > 25) {
    # Summer outfit
    outfit$top <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'tops' AND season = 'summer' ORDER BY RANDOM() LIMIT 1")
    outfit$bottom <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'shorts' AND season = 'summer' ORDER BY RANDOM() LIMIT 1")
    outfit$shoes <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'shoes' AND season = 'summer' ORDER BY RANDOM() LIMIT 1")
    outfit$accessory <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'accessories' AND season = 'summer' ORDER BY RANDOM() LIMIT 1")
    bg_color <- "#f1c454"  # Bright color for summer
  } else if (temperature >= 15 && temperature <= 25) {
    # Rainy season outfit
    outfit$top <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'tops' AND season = 'rainy' ORDER BY RANDOM() LIMIT 1")
    outfit$bottom <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'trousers' AND season = 'rainy' ORDER BY RANDOM() LIMIT 1")
    outfit$shoes <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'shoes' AND season = 'rainy' ORDER BY RANDOM() LIMIT 1")
    bg_color <- "#f8c013"  # Yellowish color for rainy weather
    outfit$accessory <- NULL  # Optional: No accessory in rainy weather
  } else {
    # Winter outfit
    outfit$top <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'tops' AND season = 'winter' ORDER BY RANDOM() LIMIT 1")
    outfit$bottom <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'trousers' AND season = 'winter' ORDER BY RANDOM() LIMIT 1")
    outfit$shoes <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'shoes' AND season = 'winter' ORDER BY RANDOM() LIMIT 1")
    outfit$coat <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'coats' AND season = 'winter' ORDER BY RANDOM() LIMIT 1")
    outfit$accessory <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'accessories' AND season = 'winter' ORDER BY RANDOM() LIMIT 1")
    bg_color <- "#74a5c3"  # Cool color for winter
  }
  
  # Add a random bag to the outfit
  outfit$bag <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'bags' ORDER BY RANDOM() LIMIT 1")
  
  # If the weather description contains "Rain", include an umbrella
  if (grepl("Rain", weather_desc)) {
    outfit$umbrella <- dbGetQuery(conn, "SELECT * FROM closet WHERE category = 'accessories' AND season = 'rainy' ORDER BY RANDOM() LIMIT 1")
  }
  
  # Specify the output file for the weather plot
  output_file <- "weather_plot.png"
  
  # Open a graphics device to create a plot
  png(output_file, width = 1000, height = 800)
  
  # Create a new plot and add elements
  plot.new()
  plot.window(xlim = c(0, 1), ylim = c(0, 1))
  rect(0, 0, 1, 1, col = bg_color, border = "black", lwd = 2)  # Background with border
  text(0.9, 0.9, "Today's Weather", cex = 1.5)  # Title
  text(0.9, 0.8, format(Sys.Date(), format = "%d %B, %Y"), cex = 1.3)  # Date
  text(0.9, 0.7, paste(temperature, "\u00B0C | ", weather_desc), cex = 1.2)  # Weather details
  
  # Scale and arrange outfit images using magick
  top <- image_scale(image_read(outfit$top$image_path), "200%")
  bottom <- image_scale(image_read(outfit$bottom$image_path), "200%")
  shoes <- image_scale(image_read(outfit$shoes$image_path), "200%")
  bag <- image_scale(image_read(outfit$bag$image_path), "200%")
  combined_image <- image_append(c(top, bottom), stack = TRUE)
  
  # Add coat if available
  if (length(outfit$coat) >= 1) {
    coat <- image_resize(image_read(outfit$coat$image_path), paste0("x", img_height))
    combined_image <- image_append(c(combined_image, coat), stack = FALSE)
  }
  
  # Combine bag and shoes into a single row
  shoes_and_bag <- image_resize(image_append(c(bag, shoes), stack = TRUE), paste0("x", img_height))
  combined_image <- image_append(c(combined_image, shoes_and_bag), stack = FALSE)
  
  # Handle umbrellas and accessories based on their availability
  # ...
  
  # Scale and save the combined image
  image_scale(combined_image, "200%")
  temp_image_path <- tempfile(fileext = ".png")
  image_write(combined_image, path = temp_image_path, format = "png")
  
  # Add weather icon to the plot
  icon_url <- weather_data$weather_icon[[1]]
  icon <- image_read(icon_url)
  icon_raster <- as.raster(icon)
  rasterImage(icon_raster, xleft = 0.85, ybottom = 0.5, xright = 0.95, ytop = 0.63)
  
  # Close the graphics device
  dev.off()
  
  # Return the path to the output file
  return(output_file)
}

#* Get Raw Product Data
#* @get /rawdata
function() {
  # Connect to the SQLite database
  conn <- dbConnect(SQLite(), dbname = "closet.db")
  
  # Retrieve all data from the closet table
  data <- dbGetQuery(conn, "SELECT * FROM closet")
  
  # Close the database connection
  dbDisconnect(conn)
  
  # Convert the data to JSON format and return it
  return(toJSON(data))
}

#* Close the API
#* @get /shutdown
function() {
  # Stop the R session to shut down the API
  quit("no")
}

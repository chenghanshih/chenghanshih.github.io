+++
authors = ["Cheng-Han Shih"]
title = "Plotting Bus Routes Based on GGMap"
date = "2024-04-20"
description = ""
categories = [
    "R",
]
tags = [
    "R Plotting",
    "GGMAP",
]
# series = ["Theme Demo"]
+++

This code uses the ggmap and ggforce libraries in R to draw a map and mark circular areas within a specified radius around given locations on the map. Below are the main steps of the code:

1. **Setting up Packages and Google Maps API Key**: First, we load ggmap and use the register_google function to set the Google Maps API key. This is necessary to utilize Google Maps' mapping services. The ggforce library is used to call Google Maps for subsequent plotting.
```r
library(ggmap)
library(ggforce)

# 設定 Google Maps API 金鑰
register_google(key = apikey)
```

2. **Reading Data**: Read the list of place names from a specified CSV file. This file contains the sequence and names of the stations. It is important to specify the format as UTF-8; otherwise, there might be issues with properly reading Chinese strings.

```r
station <- read.csv("/Users/hans/Documents/taroko_bus/data/station.csv", encoding = "UTF-8")
```

3. **Geocoding**: Use the geocode function to convert the station names from the list of place names into geographic coordinates (longitude and latitude). Since we cannot always get the correct address on the first try, we assist Google Maps' search by adding keywords. We also filter out incorrect search results, such as those outside of Taiwan, and re-search those again.

```r
# 要轉換的地名列表
locations <- data.frame(count=station$站序8181[1:38], 
                        station=station$站名8181[1:38])
taitung_add <- "taitung, taitung city, taitung county, taiwan 950"
words <- c("", "公車站", "站", "車站", "花蓮", "台東")

location_row <- 1:dim(locations)[1]
geocodeds <- data.frame()
for(word in words){
  geocoded <- geocode(paste0(locations$station, word), 
                      output = "more", source = "google")
  geocoded <- cbind(location_row, geocoded)
  if(word=="花蓮"){
    inspace <- which(geocoded$location_row>9)
    geocoded$address[inspace] <- NA
  }else if(word=="台東"){
    geocoded$address[which(geocoded$address==taitung_add)] <- NA
  }
  locations <- locations[which(is.na(geocoded$address)==T |
                               geocoded$lon>=125 | geocoded$lon<=120 | 
                               geocoded$lat>=25 | geocoded$lat<=21),]
  geocoded <- geocoded[which(is.na(geocoded$address)==F & 
                             geocoded$lon<=125 & geocoded$lon>=120 & 
                             geocoded$lat<=25 & geocoded$lat>=21),]
  geocodeds <- rbind(geocodeds, geocoded)
  location_row <- locations$count
}
```

4. **Calculating Circular Coordinates**: Calculate the coordinates of the circular area based on the specified center point's longitude and latitude and the radius.
```r
# 指定中心點經緯度和半徑
center <- data.frame(lon = geocodeds$lon, lat = geocodeds$lat)  # 中心點的經緯度
radius_km <- 1  # 半徑，單位為公里

# 將半徑從公里轉換為度
radius_deg <- radius_km / 111.32  # 每緯度大約111.32公里
```

5. **Plotting the Map**: Use the get_map function to obtain the map image, and then use the ggmap function to load the map into the output. Next, use the geom_point and geom_path functions to mark the center point and the circular area on the map. Finally, display the result on the map.
```r
# 使用 get_map 函數取得地圖圖像
map <- get_map(location = c(center$lon[10], center$lat[10]), zoom = 11)
output <- ggmap(map)

for(i in 1:nrow(geocodeds)){# 計算圓形的坐標點
  
  circle_points <- data.frame(
    lon = center$lon[i] + radius_deg * cos(seq(0, 2*pi, length.out = 100)),
    lat = center$lat[i] + radius_deg * sin(seq(0, 2*pi, length.out = 100))
  )
  
  # 繪製地圖
  output <- output +
    geom_point(x = center$lon[i], y = center$lat[i], size = 3, color = 'red') +
    geom_path(data = circle_points, aes(x = lon, y = lat), color = "red", size = 1)
  
}

output
```

Below is the final result displayed on the map. The red dots represent the locations of the bus stops, and the outer circles mark areas with a radius of one kilometer.

![GGmap_example](/images/R_ggmap/GGmap_example.png)
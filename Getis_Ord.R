#Local Getis-Ord Gi and Gi*
#Local G
lg <- localG(PopDen, listw = crd.lw, zero.policy = TRUE)
lg #there are no p-values associated with the z-scores, we can calculate those manually
#Local G p-values
lg.pval <- pnorm(2*(abs(as.vector(lg))), lower.tail = FALSE)

#Local Gi*, the difference between the Gi and Gi* statistic is how the neighbourhood weights matrix is defined.
#The Gi* includes the region itself in the definition of the spatial neighbourhood, the Gi does not
#To get the Gi*, we modify the weights matrix defined early to "include.self"
lgs <- localG(PopDen, listw = nb2listw(include.self(crd.nb), style = "W"), zero.policy = TRUE)
#Local Gi* p-values ##**NOT SURE WE WANT TO INCLUDE THESE, but they can be used to identify the hotspots/coldspots
lgs.pval <- pnorm(2*(abs(as.vector(lgs))), lower.tail = FALSE)

#Plots of the Local Gi and Local Gi* z-values
#Local Gi
gi.shades <- auto.shading(c(lg,-lg),cols=brewer.pal(5,"PRGn"))
x11()
choropleth(crd.data, lg, shading=gi.shades)
choro.legend(3862000, 1965000, gi.shades, fmt="%6.2f")

#Local Gi*
gis.shades <- auto.shading(c(lgs,-lgs),cols=brewer.pal(5,"PRGn"))
choropleth(crd.data, lgs, shading=gis.shades)
choro.legend(3860000, 1965000, gis.shades, fmt="%6.2f")

#To get clusters of high value and low values for the Gi* (similar to ArcGIS), we can use the p-values
#Create a data.frame of the z-values and p-values
gi.DF <- data.frame(gi.z = as.vector(lgs), pval = lgs.pval)

#find z-scores and p-vals for hotspots. sig hotspots = 1
gi.DF$gi.high <- ifelse(gi.DF$gi.z >= 1.96 & gi.DF$pval <= 0.05, 1, 0)
#same for cold. sig coldspots = 2
gi.DF$gi.low <- ifelse(gi.DF$gi.z <= 1.96 & gi.DF$pval <= 0.05, 2, 0)
#just add them together, nice thing about doing it this way is the values should always be:
#0 = no sig, 1 = sig hot (high), 2 = sig cold (low). If you get values of 3 something went wrong!
gi.DF$gi.sig <- gi.DF$gi.high + gi.DF$gi.low

#Now map the clusters
#We'll join the Gi* data frame to the crd.data SpatialPolygonsDataFrame to make the map, then write a file that can be used in another GIS
gi.DF$ADAUID <- crd.data$ADAUID
crd.out <- merge(crd.data, gi.DF, by = "ADAUID")
#convert the gi.sig to a factor
crd.out$gi.sig <- factor(crd.out$gi.sig)
#rename the factor levels for the plot
crd.out$gi.sig <- revalue(crd.out$gi.sig, replace = c("0" = "Not Significant", "1" = "High Values", "2" = "Low Values"))

###Spatial Polygons plot
spplot(crd.out, "gi.sig", col.regions = c("white", "red", "blue"), main = "Gi* Clusters - Population Density")

#Easily write the crd.out SpatialPolygonsDataFrame to file as a shapefile
shapefile(crd.out, "crd.shp") #you'll get a warnings saying "Field names abbreviated" because ESRI has a 10 character limit on column names
#the shapefile "crd" can be used in other GIS software (ArcGIS, QGIS etc.)


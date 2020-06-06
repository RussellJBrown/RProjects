###Create Spatial Neighbourhood Weights Matrix ###
#queen's neighbour
crd.nb <- poly2nb(crd.data)

x11()
plot(crd.data)
plot(crd.nb, coordinates(crd.data), add = TRUE, col = "red")

#rooks neighbour
crd.nb2 <- poly2nb(crd.data, queen = FALSE)
c#Now, create a new map that overlays the rook neighbors file (in yellow) onto the queen neighbors file (in red).
plot(crd.data, border = "lightgrey")
plot(crd.nb, coordinates(crd.data), add = TRUE, col = "red")
plot(crd.nb2, coordinates(crd.data), add = TRUE, col = "yellow", lwd = 2)

title("Rooks Neighbour")

#Create the spatial weights neighbour list using the queen's case
crd.lw <- nb2listw(crd.nb, zero.policy = TRUE, style = "W")
plot(crd.lw, coordinates(crd.data), add = TRUE, col = "yellow", lwd = 2)

print.listw(crd.lw, zero.policy = TRUE)

###Create lagged Means Map###
#Look at population density per km2
#lagged means
x11()
PopDen.lagged.means = lag.listw(crd.lw, PopDen, zero.policy = TRUE)
PopDen.lagged.means
#Map the lagged means using a new shading object called shades2
shades2 <- auto.shading(PopDen.lagged.means, n=6, cols = brewer.pal(6, 'Oranges'))
choropleth(crd.data, PopDen.lagged.means,shades2)
choro.legend(3864000, 1965000, shades2)

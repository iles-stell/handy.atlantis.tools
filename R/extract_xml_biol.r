# install.packages("rgl")
# library(plot3D)
# library(raster)
# library(rgl)
# library(plotly)
# library(corrplot)
# # Example data
# data <- data.frame(
#   C = c(0.5, 0.3, 0.6, 0.8, 0.07, 0.09), 
#   mQ = c(0.2, 0.7, 0.9, 0.5, 0.3, 0.6), 
#   RelB = c(0.3, 0.6, 1.5, 1, 0.8, 0.5)
# )

# scatter3D(x=data$C, y=data$mQ, z=data$RelB, bty = "g",   pch = 20, cex = 2, ticktype = "detailed")

# # Fit the linear model
# model <- lm(RelB ~ C + mQ, data = data)

# # Print model summary
# summary(model)

# # Print the coefficients
# coefficients(model)

# # If you want to create a function based on these coefficients, you can extract them like this:
# a <- coef(model)[1]  # Intercept
# b <- coef(model)[2]  # Coefficient for C
# c <- coef(model)[3]  # Coefficient for mQ

# # Print the extracted coefficients
# cat("Intercept (a):", a, "\nCoefficient for C (b):", b, "\nCoefficient for mQ (c):", c, "\n")

# # Now you can use these coefficients to predict RelB for given values of C and mQ
# predict_RelB <- function(C, mQ) {
#   a + b * C + c * mQ
# }

# # Test the function with some values of C and mQ
# predicted_RelB <- predict_RelB(0.3, 0.000002)
# cat("Predicted RelB:", predicted_RelB, "\n")

# library(MASS)
# best.model <- stepAIC(model, trace = T)

# #####################################

# library(xml2)
# library(rvest)

# base_path = ("C:\\Users\\ilarias\\OneDrive - University of Tasmania\\AtlantisRepository\\EA_WIP\\EA_model_files_basicfoodweb_orig\\output_EA_20231008_EA_biol_newdiet_v30_B_C_ZG_T15_0.002_ZG_mQ_1e-08")
# # Load the XML file
# xml_file <- read_xml(file.path(base_path, "EA_biol_newdiet_v30_B_C_ZG_T15_0.002_ZG_mQ_1e-08.xml"))

# # Extract value from XML file
# node_C <- xml_find_all(xml_file, "//Attribute[@AttributeName='InvertebrateClearanceRate']/GroupValue[@GroupName='ZG']")
# attribute_value_C <- xml_attr(node, "AttributeValue")

# node_mQ <- xml_find_all(xml_file, "//Attribute[@AttributeName='FLAG_MQ_T15']/GroupValue[@GroupName='ZG']")
# attribute_value_mQ <- xml_attr(node_mQ, "AttributeValue")
# print(attribute_value_C)
# print(attribute_value_mQ)


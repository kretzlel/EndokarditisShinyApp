#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinymanager)
source("sql.R")
source("myUI.R")

# Define UI for application that draws a histogram
# ui <- fluidPage(
# 
#     # Application title
#     titlePanel("EndokarditisPal"),
# 
# 
#     sidebarLayout(
#         sidebarPanel(
#           helpText("Hallo")
#         ),
#             
#         mainPanel(
#           textOutput("patient")
#         )
#     )
# )

ui <- myUI
ui <- secure_app(ui, language="de")


server <- function(input, output, session) {
  
    res_auth <- secure_server(
      check_credentials = function(username, password) {
        if (authenticateUser(username, password)) {
          list(result = TRUE, user_info = list(user=user$username, something=user$linkedPatient))
        } else {
          list(result = FALSE)
        }
      }
    )
  
    output$patient <- renderText({ user$linkedPatient })

}

shinyApp(ui = ui, server = server)

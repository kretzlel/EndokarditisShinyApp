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
#source("test.R")

library(RMySQL)

ui <- myUI
ui <- secure_app(ui, language="de")
diaryEntry <- NULL

# Define Server Logic ----
server <- function(input, output, session) {
  output$bsa <- renderText({0.007184 * input$groesse^0.725 * input$gewicht^0.425}) # DuBois
  
  res_auth <- secure_server(
      check_credentials = function(username, password) {
        if (authenticateUser(username, password)) {
          list(result = TRUE, user_info = list(user=user$username, something=user$linkedPatient))
        } else {
          list(result = FALSE)
        }
      }
    )

  output$bsa <- renderText({0.007184 * input$groesse^0.725 * input$gewicht^0.425}) # DuBois

  observeEvent(input$submit, {
    databaseName <- "endocarditisapp"
    table <- "Symptoms"
    
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    
    data <- c(user$linkedPatient, format(input$Datum, "'%Y-%m-%d'"), input$fieber == 1, sum(1*(input$symptome == 1)) == 1, sum(1*(input$symptome == 3)) == 1)
    names(data) <- c("PatientId", "Date", "Fever", "Headache", "Malaise")
    
    query <- sprintf(
      "INSERT INTO %s (%s) VALUES (%s)",
      table, 
      paste(names(data), collapse = ", "),
      paste(data, collapse = ", ")
    )
    # Submit the update query and disconnect
    dbGetQuery(db, query)
    dbDisconnect(db)
    showModal(modalDialog(
      title = "Ihre Daten sind gespeichert.",
      paste0("Ihre Daten sind jetzt gespeichert"),
      easyClose = TRUE,
      footer = NULL
    ))
  })
  
  output$welcomeMessage <- renderText ({
    if (user$healthcareProvider == 0) {
      sprintf("Herzlich Willkommen, %s.", getPatientName(user$linkedPatient))
    } else {
      sprintf("Herzlich Willkommen. Ihr Patient: %s", getPatientName(user$linkedPatient))
    }  
    })
  
    output$appTitle <- renderText({
      patName = getPatientName(user$linkedPatient)
      if (is.null(patName)) {
        return ("EndokarditisApp")
      } else {
        sprintf("EndokarditisApp für %s", patName)
      }
    })
    
    output$tagebuchGespeichert <- renderText({
      diaryEntry <- retrieveDiaryEntry(user$linkedPatient, input$Datum)
      if (is.null(diaryEntry)) {
        return ("Für dieses Datum wurde noch kein Eintrag gespeichert")
      } else {
        sprintf("Dieser Eintrag wurde zuletzt am %s bearbeitet.", as.Date(diaryEntry$LastEdited, "%Y-%m-%d"))  
      }
    })
    
    
    # observeEvent(input$Datum, {
    #   cat(file=stdout(),"observeEvent(input$Datum) wurde ausgelöst.")  
    #   if (input$Datum > Sys.Date()) {
    #     input.Datum = Sys.Date()
    #   } 
    # })
    
    output$tagebuchEintrag <- renderUI({
      retrieveDiaryEntry(user$linkedPatient, input$Datum)
      if (is.null(entry)) {
        entry <- frame(
          Date = input$Datum,
          Fever = 0,
          Headache = 0,
          Malaise = 0,
          LastEdited = SysDate()
        )
      }
      list(
      radioButtons(
        "fieber",
        "Fieber",
        choices = list("Ich habe kein Fieber" = 0, "Ich habe Fieber" = 1),
        selected = entry$Fever
      ),
      conditionalPanel(
        condition = "input.fieber == 1",
        numericInput(
          "temp",
          "gemessene Körpertemperatur",
          37.0,
          min = 35.0,
          max = 42.0,
          step = 0.1
        ),
        conditionalPanel(
          condition = "input.temp > 38.5",
          conditionalPanel(
            condition = "input.temp > 44",
            h2("Bitte messen Sie noch einmal, dieser Wert ist sehr unwahrscheinlich", style = "color:yellow"),
          ),
          conditionalPanel(
            condition = "input.temp <= 44",
            h2("Kontaktieren Sie bitte Ihren Arzt", style = "color:red")
          )
        ),
      ),
      checkboxGroupInput(
        "symptome",
        "Sonstige Symptome",
        choices = list(
          "Kopfschmerzen" = 1,
          "allgemein Abgeschlagenheit" = 2,
          "Appetitlosigkeit" = 3,
          "Nachtschweiß" = 4,
          "Muskel- oder Gelenkschmerzen" = 5
        ),
        #selected = 0
        selected = if (nrow(entry)==0) 0 else c(
          if(entry$Headache==1) 1 else 0, 
          if(entry$Malaise==1) 3 else 0
        ) 
      ),
      
      #conditionalPanel wird nur angezeigt, wenn Medikamente hinterlegt sind
      checkboxGroupInput(
        "medis",
        "Gestern eingenommene Medikamente",
        choices = list(
          "Rifampicin 600 mg (z.B. EREMFAT) 1 Tablette um 8:00" = 1,
          "Rifampicin 600 mg (z.B. EREMFAT) 1 Tablette um 20:00" = 2
        ),
        selected = 0,
        width = 500
      ),
      actionButton("submit","submit", icon("save")),
      verbatimTextOutput("value")
    )})
  
    output$VorerkrankungenEingabeUI <- renderUI(
      if (user$healthcareProvider == 1) {
        hpUI
      } else {
        tagList(
          helpText("Hier dürfen nur Ärzte Eintragungen machen.")
        )
      }
    )

    
}

shinyApp(ui = ui, server = server)



# EndokarditisApp
# 
# Eine Shiny-Webapplikation zur Erfassung von Symptomen bei ambulant entlassenen Patienten nach Endokarditis

library(shiny)
library(DT)
library(plyr)
library(shinymanager)
source("sql.R")
source("myUI.R")
library(RMySQL)

ui <- myUI
ui <- secure_app(ui, language="de")

patient <<- NULL
benutzer <<- NULL

server <- function(input, output, session) {
  
  ## Helfer-Funktionen
  
  sqlSysDate <- function() { format(Sys.Date(),"'%Y-%m-%d'") }
  
  myDate <- function(datum) {
    format(as.Date(datum), "%d.%m.%Y")
  }
  
  # Generiert ein Text-String, welches den Verfügbarkeitszeitraum für die App ausgibt
  appVerfuegbarkeit <- function() {
    paste("Die Tagebuchfunktion steht zur Verfügung für die Daten vom ", myDate(patient$beginn), "bis zum ", myDate(patient$ende),". Ab dem ", format(as.Date(patient$ende)+90, "%d.%m.%Y"), "werden sämtliche Patienten-bezogenen Daten sowie Ihre Benutzerkennung gelöscht.")
  }
  
  ## Shiny-Manager Secure-Server
  
  res_auth <- secure_server(
      check_credentials = function(username, password) {
        if (authenticateUser(username, password)) {
          list(result = TRUE, user_info = list(user=benutzer$benutzername, something=benutzer$patienten_id))
        } else {
          list(result = FALSE)
        }
      }
    )

  ## UI-Renderer
  
  # UI-Renderer Start-Tab
  output$welcomeMessage <- renderUI({
    tagList(if (benutzer$ist_arzt == 0) {
      tagList(h3(paste(
        "Herzlich Willkommen, ",
        getPatientName(benutzer$patienten_id)
      )),
      br(), br()
      )
    } else if (benutzer$ist_arzt == 1) {
      tagList(
        h3("Herzlich Willkommen."),
        strong("Ihr Patient:"), br(),
        getPatientName(benutzer$patienten_id), br(), br()
      )
    },
    "Herzlichen Dank für die Nutzung der Endokarditis App. ", br(), br(),
    em(appVerfuegbarkeit()
    )
    )
  })
  
  # UI-Renderer Text in der Sidebar des Tagebuchs
  output$tagebuchGespeichert <- renderText({
    diaryEntry <- retrieveDiaryEntry(benutzer$patienten_id, input$Datum)
    if (is.null(diaryEntry)) {
      return ("Für dieses Datum wurde noch kein Eintrag gespeichert")
    } else {
      sprintf("Dieser Eintrag wurde zuletzt am %s bearbeitet.", myDate(diaryEntry$zuletzt_geaendert))  
    }
  })
  
  # UI-Renderer für den DatePicker im Tagebuch
  output$datumsBereich <- renderUI({
    retrievePatient(benutzer$patienten_id)
    maxDate = Sys.Date();
    if (maxDate > patient$ende) {
      maxDate = patient$ende
    }
    dateInput(
      "Datum",
      label = "Datum",
      format = "dd.mm.yyyy",
      language = "de",
      weekstart = 1,
      min = patient$beginn,
      max = maxDate,
      value = maxDate
    )
  })
  
  # UI-Renderer für die Tagebucheinträge
  output$tagebuchEintrag <- renderUI({
    retrieveDiaryEntry(benutzer$patienten_id, input$Datum)
    if (is.null(entry)) {
      entry <- frame(
        id = -1,
        datum = input$Datum,
        fieber = 0,
        fieber_temperatur = NULL,
        kopfschmerzen = 0,
        abgeschlagenheit = 0,
        appetitlosigkeit = 0,
        nachtschweiss = 0,
        muskel_gelenkschmerzen = 0,
        zuletzt_geaendert = SysDate()
      )
    }
    list(
      radioButtons(
        "fieber",
        "Fieber",
        choices = list("Ich habe kein Fieber" = 0, "Ich habe Fieber" = 1),
        selected = entry$fieber
      ),
      conditionalPanel(
        condition = "input.fieber == 1",
        numericInput(
          "temp",
          "gemessene Körpertemperatur",
          entry$fieber_temperatur,
          min = 35.0,
          max = 42.0,
          step = 0.1
        )
        
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
        selected = if (nrow(entry)==0) 0 else c(
          if(entry$kopfschmerzen==1) 1 else 0, 
          if(entry$abgeschlagenheit==1) 2 else 0,
          if(entry$appetitlosigkeit==1) 3 else 0,
          if(entry$nachtschweiss==1) 4 else 0,
          if(entry$muskel_gelenkschmerzen==1) 5 else 0
        ) 
      ),
      
      actionButton("submit","Eintrag speichern", icon("save")), br(), br(),
      #verbatimTextOutput("value")
      appVerfuegbarkeit()
    )})
  
  # UI-Renderer für die Arztangaben
  output$arztangaben <- renderUI({
    tagList(
      strong("Vorname Patient"), br(),
      patient$vorname, br(), br(),
      strong("Nachname Patient"), br(),
      patient$nachname, br(), br(),
      strong("Geburtsdatum"),br(),
      myDate(patient$geburtsdatum), br(), br(),
      strong("Geschlecht"), br(),
      if (patient$geschlecht == 1) {
        "männlich"
      } else if (patient$geschlecht == 2) {
        "weiblich"
      } else {
        "divers / keine Angabe"
      }, br(), br(),
      if (benutzer$ist_arzt == 1) { 
        tagList(
          textAreaInput("diagnosen", "Diagnosen / Vorgeschichte", width='80%', height=200, value = patient$vorgeschichte, placeholder="Bitte Verlauf / relevante Diagnosen aufführen."),
          textAreaInput("kontaktdaten", "Diese Kontaktdaten werden Ihrem Patienten angezeigt", width='80%', height=100, value = patient$arztkontakt, placeholder="Bitte tragen Sie hier ein, wie der Patient Sie oder einen betreuenden Arzt erreichen kann.")
        )
      } else {
        tagList(
          strong("Diagnosen / Vorgeschichte"), br(),
          verbatimTextOutput("formatierteVorgeschichte"), br(), br()
        )
      },
      em(appVerfuegbarkeit()), br(), br(),
      if (benutzer$ist_arzt == 1) {
        actionButton("arztangabenSpeichern","Änderungen speichern", icon("save"))
      } 
    )})
  
  # UI-Renderer für die formatierte Patientengeschichte und den Arztkontakt
  output$formatierteVorgeschichte <- renderText(patient$vorgeschichte)
  output$formatierteKontaktdaten <- renderText(patient$arztkontakt)
  output$arztkontakt <- renderUI({
    tagList(
      strong("So erreichen Sie Ihren Arzt:"), br(),
      verbatimTextOutput("formatierteKontaktdaten"), br(), br()
    )
  })
  
  # UI-Renderer für die Zusammenfassung der Tagebucheinträge
  output$alleEintraege <- renderDT({
    zusammenfassung <<- alleEintraegeEinlesen(benutzer$patienten_id)
    invalidateLater(30000)
    datatable(zusammenfassung,
              options = list(order = list(1,'desc'),
                             "searching" = FALSE,
                             "columnDefs" = list(list("targets" = 0, "visible" = FALSE)))
    )
  })
  
  ## Event-Observer
  
  # Tagebucheintrag abspeichern
  observeEvent(input$submit, {
  
    if ((input$fieber == 1) && (!is.na(input$temp)) && ((input$temp < 35.0) || (input$temp > 43.0))) {
      showModal(
        modalDialog(
          strong("Sie haben eine ungütlige Temperatur eingegeben"), br(), br(),
          p("Temperaturen über 43.0 Grad sind sehr unwahrscheinlich. Möglicherweise liegt ein Defekt Ihres Thermometers vor. Messen Sie gegebenenfalls noch einmal nach."), br(),
          p("Lassen Sie sonst das Feld einfach frei."),
          title="Daten wurden nicht gespeichert.",
          icon=icon("circle-exclamation"),
          easyClose=FALSE
        )
      )
      return()
    }
    
    databaseName <- "endocarditisapp"
    table <- "tagebuch_eintraege"
    
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    
    data <- c(benutzer$patienten_id, format(input$Datum, "'%Y-%m-%d'"), sum(1*(input$fieber==1)), input$temp, sum(1*(input$symptome == 1)), sum(1*(input$symptome == 2)), sum(1*(input$symptome == 3)), sum(1*(input$symptome == 4)),sum(1*(input$symptome == 5)),sqlSysDate())
    names(data) <- c("patienten_id", "datum", "fieber", "fieber_temperatur", "kopfschmerzen", "abgeschlagenheit", "appetitlosigkeit", "nachtschweiss", "muskel_gelenkschmerzen", "zuletzt_geaendert")
    if ((is.na(data["fieber_temperatur"])) || (input$fieber == 0)) {
      data["fieber_temperatur"] = "NULL"
    }
        query <- sprintf("SELECT * FROM %s WHERE patienten_id='%s' AND datum=%s", table, benutzer$patienten_id, format(input$Datum, "'%Y-%m-%d'")) 

    entry <<- dbGetQuery(db, query)
    if (nrow(entry)==0) {
      query <- sprintf(
        "INSERT INTO %s (%s) VALUES (%s)",
        table, 
        paste(names(data), collapse = ", "),
        paste(data, collapse = ", ")
      )
    } else {
      query <- sprintf(
        "UPDATE %s SET `fieber`='%s',`fieber_temperatur`=%s,`kopfschmerzen`='%s',`abgeschlagenheit`='%s',`appetitlosigkeit`='%s',`nachtschweiss`='%s',`muskel_gelenkschmerzen`='%s', `zuletzt_geaendert`=%s WHERE `id`=%s",
        table, 
        input$fieber,  
        data["fieber_temperatur"], 
        sum(1*(input$symptome == 1)), 
        sum(1*(input$symptome == 2)), 
        sum(1*(input$symptome == 3)), 
        sum(1*(input$symptome == 4)),
        sum(1*(input$symptome == 5)), 
        sqlSysDate(),
        entry$id
      )
    }

    dbGetQuery(db, query)
    dbDisconnect(db)
    
    if ((input$fieber == 1) || (length(input$symptome) > 0)) {
      showModal(
        modalDialog(
          strong("Sie haben oder hatten Fieber oder auffällige Symptome.", style = "color:red"),
          br(), br(),
          strong("Falls noch nicht geschehen, kontaktieren Sie bitte Ihren Arzt"),
          br(), br(),
          "Sie erreichen Ihren Arzt unter:",
          verbatimTextOutput("formatierteKontaktdaten"),
          title = "Die Daten wurden gespeichert.",
          easyClose = TRUE
        )
      )
    } else {
      showModal(
        modalDialog(
          p("Falls Sie sich anderweitig unwohl fühlen sollten oder Fragen haben, kontaktieren Sie gegebenenfalls Ihren Arzt"), 
          title="Die Daten wurden gespeichert", 
          easyClose = TRUE
        )
      )
    }
    output$tagebuchGespeichert <- renderText ({
      "Dieser Eintrag wurde soeben gespeichert."
    })
    
  })
  
  # Arztangaben abspeichern
  observeEvent(input$arztangabenSpeichern, {
    databaseName <- "endocarditisapp"
    table <- "patienten"
    
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    
    data <- c(patient$vorname, patient$nachname, patient$geschlecht, patient$vorgeschichte, patient$arztkontakt, patient$id)
    names(data) <- c("vorname", "nachname", "geschlecht", "vorgeschichte", "arztkontakt", "id")

 
    query <- sprintf(
        "UPDATE %s SET `vorgeschichte`='%s', `arztkontakt`='%s' WHERE `id`=%s",
        table, 
        input$diagnosen,
        input$kontaktdaten,
        patient$id
      )

    dbGetQuery(db, query)
    dbDisconnect(db)
    
    showModal(modalDialog(
      title = "Die Änderungen wurden gespeichert.",
      easyClose = TRUE,
      footer = NULL
    ))
  })
  
  ## UI-Anpassung an Benutzerrechte  
  observe({
    if (!is.null(benutzer)) { 
     if (benutzer$ist_arzt) {
        hideTab(inputId = "tabs", target="Tagebuch")  
        showTab(inputId = "tabs", target="Verlauf")
        hideTab(inputId = "tabs", target="Arztkontakt")
     } else {
        showTab(inputId = "tabs", target="Tagebuch")
        hideTab(inputId = "tabs", target="Verlauf")
        showTab(inputId = "tabs", target="Arztkontakt")
     }
    }
  })
  
}

shinyApp(ui = ui, server = server)



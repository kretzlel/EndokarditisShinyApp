## UI-Elemente
## Copyright (C) 2022 Timm M. Kandaouroff

myUI <- navbarPage(
  "EndokarditisApp", id = "tabs",
  windowTitle = "EndokarditisApp",
  
  tabPanel("Start",
    fluidPage(
      uiOutput("welcomeMessage")
    )       
  ),
  
  tabPanel("Tagebuch",
           sidebarLayout(
             sidebarPanel(
               uiOutput("datumsBereich"),
               textOutput("tagebuchGespeichert", container = tags$small),
             ),
             mainPanel(
               NULL,
               uiOutput("tagebuchEintrag")
             )
           )
        ),

  tabPanel("Verlauf",
    fluidPage(
      DTOutput("alleEintraege"),
      br(),
      helpText("Änderungen in den Tagebucheinträgen werden erst nach maximal 30 Sekunden sichtbar!"),
    )
  ),
  
  tabPanel("Arztangaben", fluidPage(
      uiOutput("arztangaben")
  )),
    
  tabPanel("Arztkontakt", fluidPage(
    uiOutput("arztkontakt")
  )),
  
  )

  


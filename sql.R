# Funktionen zur Authentifizierung und Privilegienabfrage für die SinyEndokarditis-App

library (RMySQL)
library (bcrypt)

# Die Userdatenbank muss sich in einer MySQL-Datenbank (Standard: "shinyusers") mit den unter options() engestellten Parametern befinden
# In der Datenbank muss sich eine Tabelle (Standard "users") mit den folgenden Feldern befinden:
# username            varchar primary required        Der Benutzername in Klartext
# password            varchar required                Das Password als BCrypt-Hash 
# admin               boolean/tinyint(1)              Admin-Privilegien ja/nein
# healthcareProvider  boolean/tinyint(1)              Arzt-Privilegien ja/nein
# linkedPatient       int required                    Verbundene Patienten-ID
options(mysql = list(
  "host" = "127.0.0.1",
  "port" = 8889,
  "user" = "endokarditis",
  "password" = "karsuc-poncav-warbU2"
))
## Beispiel-Datenbank
## kardiostar kardiostar
## Mitra Clip
databaseName <- "endocarditisapp"
table <- "users"

user = NULL

# Funktion addHashedUser(username, password, admin, healthcareProvider, linkedPatient) fügt einen neuen User zur Datenbank hinzu
addUser <- function(username, password, admin, healthcareProvider, linkedPatient) {
  hashedPassword <- hashpw(password, salt=gensalt())
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, port = options()$mysql$port, user = options()$mysql$user, password=options()$mysql$password)
  query <- sprintf("INSERT INTO `%s` (`username`, `password`, `admin`, `healthcareProvider`, `linkedPatient`) VALUES ('%s', '%s', '%i', '%i', '%i');", table, username, hashedPassword, admin, healthcareProvider, linkedPatient)
  dbGetQuery(db, query)
  dbDisconnect(db)
}

# Funktion authenticateUser(username, password) authentifiziert Benutzer, gibt das Ergebnis als TRUE/FALSE zurück und
# lädt den Benutzer mit seinen Privilegien in die Globale Variable "user"
authenticateUser <- function(username, password) {
  table <- "users"
  user <<- NULL
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, port = options()$mysql$port, user = options()$mysql$user, password=options()$mysql$password)
  query <- sprintf("SELECT * FROM %s WHERE username='%s'", table, username) # da "username" primary key ist, kann maximal 1 Benutzer zurückgegeben werden
  user <<- dbGetQuery(db, query)
  dbDisconnect(db)
  if (nrow(user) > 0) {
    tryCatch({
      check = checkpw(password, user$password)
      if (!check) {
        user <<- NULL
        return(FALSE)
      } else {
        return(TRUE)
      }
    }, error = function(e) {
      return(FALSE)
    }, finally = {
      user$password <<- NULL
    })
  }
}

getPatientName <- function(PatientID) {
    table <- "Patients"
    
    db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    
    query <- sprintf("SELECT * FROM %s WHERE Id='%s'", table, PatientID) 
    patient <<- dbGetQuery(db, query)
    dbDisconnect(db)
    
    if (nrow(patient)==0) {
     return (NULL) 
    } else {
     return(paste(patient$FirstName,patient$LastName))
    }
}

retrieveDiaryEntry <- function(patientID, entryDate) {
  table <- "Symptoms"
  db <- dbConnect(MySQL(), dbname = databaseName, host = options()$mysql$host, 
                  port = options()$mysql$port, user = options()$mysql$user, 
                  password = options()$mysql$password)
  if (is.null(entryDate)) {
    stop("entryDate ist NULL")
    entryDate = "2222-22-22"
  }
  query <- sprintf("SELECT * FROM %s WHERE PatientId='%s' AND Date=%s", table, patientID, format(entryDate, "'%Y-%m-%d'")) 
  entry <<- dbGetQuery(db, query)
  dbDisconnect(db)
  if (nrow(entry) == 0) {
    # cat(file=stdout(), "retrieveDiaryEntry: Kein Eintrag für Patient", patientID, " am Datum ", format(entryDate, "'%Y-%m-%d'"), " gefunden.\n")
    return (NULL)
  } else if (nrow(entry) > 1) {
    stop("Datenbank-Integrität beeinträchtigt. Es befindet sich mehr als ein Eintrag in der Datenbank zu diesem Patienten und diesem Datum. Bitte kontaktieren Sie xxxxxxx")  
  } else {
    # cat(file=stdout(), "retrieveDiaryEntry: Ein Eintrag für Patient", patientID, " am Datum ", format(entryDate, "'%Y-%m-%d'"), " wurde gefunden.\n")
    return (entry)
  }
}



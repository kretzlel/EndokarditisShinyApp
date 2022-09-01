# Funktionen zur Authentifizierung und Privilegienabfrage für die SinyEndokarditis-App

# Automatically close database connection: 
# https://community.rstudio.com/t/disconnect-from-mysql-when-user-exits/21882



library (RMySQL)
library (bcrypt)

options(mysql = list(
  "host" = "127.0.0.1",
  "port" = 8889,
  "user" = "endokarditis",
  "password" = "karsuc-poncav-warbU2" # TODO: Verschlüsselung mittels White-Box-Cryptography
))
dbName <- "endocarditisapp"

# Funktion addUser(benutzername, passwort, admin, ist_arzt, patienten_id) fügt einen neuen benutzer zur Datenbank hinzu
# addUser <- function(benutzername, passwort, admin, ist_arzt, patienten_id) {
#   passwort_hash <- hashpw(passwort, salt=gensalt())
#   db <- dbConnect(MySQL(), dbname = dbName, host = options()$mysql$host, port = options()$mysql$port, user = options()$mysql$benutzer, password=options()$mysql$password)
#   query <- sprintf("INSERT INTO `%s` (`benutzername`, `passwort_hash`, `admin`, `ist_arzt`, `patienten_id`) VALUES ('%s', '%s', '%i', '%i', '%i');", tabelle, benutzername, passwort_hash, admin, ist_arzt, patienten_id)
#   dbGetQuery(db, query)
#   dbDisconnect(db)
# }

# Funktion authenticateUser(benutzername, passwort) authentifiziert Benutzer, gibt das Ergebnis als TRUE/FALSE zurück und
# lädt den Benutzer mit seinen Privilegien in die Globale Variable "benutzer"
authenticateUser <- function(benutzername, passwort) {
  tabelle <- "benutzer"
  benutzer <<- NULL
  db <- dbConnect(MySQL(), dbname = dbName, host = options()$mysql$host, port = options()$mysql$port, user = options()$mysql$user, password=options()$mysql$password)
  query <- sprintf("SELECT * FROM %s WHERE benutzername='%s'", tabelle, benutzername) # da "benutzername" primary key ist, kann maximal 1 Benutzer zurückgegeben werden
  benutzer <<- dbGetQuery(db, query)
  dbDisconnect(db)
  if (nrow(benutzer) > 0) {
    tryCatch({
      check = checkpw(passwort, benutzer$passwort_hash)
      if (!check) {
        benutzer <<- NULL
        return(FALSE)
      } else {
        return(TRUE)
      }
    }, error = function(e) {
      return(FALSE)
    }, finally = {
      benutzer$passwort_hash <<- NULL
    })
  }
}

getPatientName <- function(patientID) {
    tabelle <- "patienten"
    
    db <- dbConnect(MySQL(), dbname = dbName, host = options()$mysql$host, 
                    port = options()$mysql$port, user = options()$mysql$user, 
                    password = options()$mysql$password)
    
    query <- sprintf("SELECT * FROM %s WHERE id='%s'", tabelle, patientID) 
    patient <<- dbGetQuery(db, query)
    dbDisconnect(db)
    
    if (nrow(patient)==0) {
     return (NULL) 
    } else {
     anrede = switch (patient$geschlecht,
       "1" = "Herr",
       "2" = "Frau",
       "3" = ""
     )
     return(paste(anrede,patient$vorname,patient$nachname))
    }
}

retrievePatient <- function(patientID) {
  tabelle <- "patienten"
  
  db <- dbConnect(MySQL(), dbname = dbName, host = options()$mysql$host, 
                  port = options()$mysql$port, user = options()$mysql$user, 
                  password = options()$mysql$password)
  
  query <- sprintf("SELECT * FROM %s WHERE id='%s'", tabelle, patientID) 
  patient <<- dbGetQuery(db, query)
  dbDisconnect(db)
}

retrieveDiaryEntry <- function(patientId, datum) {
  if (is.null(datum)) {
    return
  }
  tabelle <- "tagebuch_eintraege"
  db <- dbConnect(MySQL(), dbname = dbName, host = options()$mysql$host, 
                  port = options()$mysql$port, user = options()$mysql$user, 
                  password = options()$mysql$password)
  query <- sprintf("SELECT * FROM %s WHERE patienten_id='%s' AND datum=%s", tabelle, patientId, format(datum, "'%Y-%m-%d'")) 
  if (DEBUG_SQL) {
    cat(file=stdout(),query,"\n")
  }
  suppressWarnings({entry <<- dbGetQuery(db, query)})
  dbDisconnect(db)
  if (nrow(entry) == 0) {
   return (NULL)
  } else if (nrow(entry) > 1) {
    stop("Datenbank-Integrität beeinträchtigt. Es befindet sich mehr als ein Eintrag in der Datenbank zu diesem Patienten und diesem Datum. Bitte kontaktieren Sie xxxxxxx")  
  } else {
    return (entry)
  }
}
  
alleEintraegeEinlesen <- function(patientId) {
  tabelle <- "tagebuch_eintraege"
  db <- dbConnect(MySQL(), dbname = dbName, host = options()$mysql$host, 
                  port = options()$mysql$port, user = options()$mysql$user, 
                  password = options()$mysql$password)
  query <- sprintf("SELECT * FROM %s WHERE patienten_id='%s'", tabelle, patientId) 
  if (DEBUG_SQL) {
    cat(file=stdout(),query,"\n")
  }
  suppressWarnings({entries <<- dbGetQuery(db, query)})
  dbDisconnect(db)
  zeilen = nrow(entries)
  spaltenNamen <- c("Datum", "Zuletzt geändert", "Fieber", "Temperatur", "Symptome")
  umformatierung <- data.frame(Datum=character(zeilen), Fieber=character(zeilen), Temperatur=numeric(zeilen), Symptome=character(zeilen),Geaendert=character(zeilen))
  colnames(umformatierung) = spaltenNamen
  if (zeilen == 0) {
    return (umformatierung)
  }
  umformatierung$Datum = entries["datum"]
  umformatierung["Zuletzt geändert"] = entries["zuletzt_geaendert"]
  # Fieber Ja/Nein
  umformatierung$Fieber <- mapvalues(entries$fieber,c(0,1),c("Nein","JA"))
  # Fieberhoehe
  umformatierung$Temperatur <- entries$fieber_temperatur
  # Symptome als String-Liste
  for (row in 1:zeilen) {
    syAcc = c(character(0))
    if (entries$kopfschmerzen[row]==1) {
      syAcc = c(syAcc, "Kopfschmerzen")
    }
    if (entries$abgeschlagenheit[row]==1) {
      syAcc = c(syAcc, "Abgeschlagenheit")
    }
    if (entries$appetitlosigkeit[row]==1) {
      syAcc = c(syAcc, "Appetitlosigkeit")
    }
    if (entries$nachtschweiss[row]==1) {
      syAcc = c(syAcc, "Nachtschweiss")
    }
    if (entries$muskel_gelenkschmerzen[row]==1) {
      syAcc = c(syAcc, "Muskel-/Gelenkschmerzen")
    }
    if (length(syAcc) == 0) {
      syText = "keine"
    } else {
      syText = toString(syAcc)
    }
    umformatierung$Symptome[row] = syText
  }
  return (umformatierung)
}




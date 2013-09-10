//config.js
.import QtQuick.LocalStorage 2.0 as LS
// First, let's create a short helper function to get the database connection
function getDatabase() {
    return LS.LocalStorage.openDatabaseSync("Noto", "1.0", "StorageDatabase", 100000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
                function(tx) {
                    // Create the settings table if it doesn't already exist
                    // If the table exists, this is skipped
                    tx.executeSql('CREATE TABLE IF NOT EXISTS notes(title TEXT UNIQUE,txt TEXT)');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS todos(title TEXT,todo TEXT,status INTEGER)');
                    tx.executeSql('CREATE UNIQUE INDEX IF NOT EXISTS idx ON todos(title,todo);');
                });
}

// This function is used to write notes into the database
function setNote(title,txt) {
    // title: name representing the title of the note
    // txt: text of the note
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO notes VALUES (?,?);', [title,txt]);
        //console.log(rs.rowsAffected)
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database");
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to write todos into the database
function setTodo(title,todo, status) {
    // profile: name representing the profile of the soundboard
    // nr: int representing the position in the soundboard
    // path: string representing the path to the audio
    // name: string representing the name of the audio
    var db = getDatabase();
    var res = "";
    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO todos VALUES (?,?,?);', [title,todo,status]);
        //console.log(rs.rowsAffected)
        if (rs.rowsAffected > 0) {
            res = "OK";
            console.log ("Saved to database");
        } else {
            res = "Error";
            console.log ("Error saving to database");
        }
    }
    );
    // The function returns “OK” if it was successful, or “Error” if it wasn't
    return res;
}

// This function is used to retrieve a notes from the database
function getNotes() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT DISTINCT title FROM notes;');
        for (var i = 0; i < rs.rows.length; i++) {
            root.addNote(rs.rows.item(i).title)
        }
    })
}

// This function is used to retrieve todos from the database
function getTodos() {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT DISTINCT title FROM todos;');
        for (var i = 0; i < rs.rows.length; i++) {
            root.addTodoTitle(rs.rows.item(i).title)
        }
    })
}

// This function is used to retrieve a text from a note in the database
function getText(title) {
    var db = getDatabase();
    var notesText="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT txt FROM notes WHERE title=?;', [title]);
        if (rs.rows.length > 0) {
            notesText = rs.rows.item(0).txt
        } else {
            notesText = "Unknown"
        }
    })
    // The function returns “Unknown” if the setting was not found in the database
    // For more advanced projects, this should probably be handled through error codes
    return notesText
} 

// I seem not clever enough to only make this in one function so here is another one
function getTodo(title) {
    var db = getDatabase();
    var todoText="";
    var todoStatus="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT todo,status FROM todos WHERE title=?;', [title]);
        for (var i = 0; i < rs.rows.length; i++) {
            if (rs.rows.length > 0) {
                var row = rs.rows.item(i)
                console.debug(row['todo'])
                console.debug(row['status'])
                todoPage.addTodo(row['todo'],row['status'])
            } else {
                todoText = "Unknown"
                todoStatus = 0
            }
        }
    })
    // The function returns “Unknown” if the setting was not found in the database
    // For more advanced projects, this should probably be handled through error codes
    return [todoText,todoStatus];
}

// This function is used to remove a note or todo from the database
function remove(title,type) {
    var db = getDatabase();
    var respath="";
    if (type === "note") {
        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM notes WHERE title=?;' , [title]);
        })
    }
    else if  (type === "todo") {
        db.transaction(function(tx) {
            var rs = tx.executeSql('DELETE FROM todos WHERE title=?;' , [title]);
        })
    }
}

// This function is used to remove todo entry from a todo in the database
function removeTodoEntry(title,todo) {
    var db = getDatabase();
    var respath="";
    db.transaction(function(tx) {
        var rs = tx.executeSql('DELETE FROM todos WHERE title=? AND todo=?;' , [title,todo]);
    })
}

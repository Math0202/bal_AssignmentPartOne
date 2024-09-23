import ballerina/http;
import ballerina/time;
import ballerina/log;


// Define a record to represent the Programme details
type Programme record {
    string programmeCode;
    int nqfLevel;
    string faculty;
    string department;
    string programmeTitle;
    Date registrationDate;
    int programmeLength;
    Course[] course;
    int registrationYear;
};

// Define a record for Date structure
type Date record {
    int year;
    int month;
    int day;
};

// Define a record for Course (can be expanded in the future)
type Course record {
    string courseCode;
    string courseTitle;
};

// Mock repository layer to fetch programmes
service class ProgrammeService {
    // Method to get all programmes
    function getProgrammes() returns Programme[]|error {
        Programme hr = {
            programmeCode: "HR8612", 
            nqfLevel: 7, 
            faculty: "Human Management",
            department: "Social Study",
            programmeTitle: "HR",
            registrationDate: {year: 2024, month: 6, day: 3},
            programmeLength: 5,
            course: [],
            registrationYear: 0
        };

        return [hr];
    }
}

// Initialize ProgrammeService class
ProgrammeService programmeService = new ProgrammeService();

// Define an HTTP listener on port 9090
service /programmes on new http:Listener(9090) {

    // Resource to handle GET requests for programmes
    resource function get programmes(http:Caller caller, http:Request req) returns error? {
        // Try to fetch programmes using the service layer
        Programme[]|error programmes = programmeService.getProgrammes();
        if programmes is error {
            // Log the error and send a response with status 500 (Internal Server Error)
            log:printError("Failed to fetch programmes", programmes);
            check caller->respond({statusCode: 500, reasonPhrase: "Internal Server Error"});
            return;
        }

        // If successful, return the list of programmes
        check caller->respond(programmes);
    }
}


type course record {
    
};

table<course> key(courseCode) coursesTable = table[];

service /programmes on new http:Listener(9090) {

  //test resource function
    resource function get programmes() returns Programme[]|error {
      Programme hr = {
        programmeCode: "HR8612", 
        nqfLevel: 7, 
        faculty: "Human Management",
        department: "Social Study",
        programmeTitle: "HR",
        registrationDate: {year: 2024, month: 6, day: 3},
        programmeLength: 5,
        course: [],
        registrationYear: 0};
        return [hr];
    }

    //add a programme to the database(table)
    resource function post addProgramme( Programme newProgramme) returns string {
      error? addProgrammeResults = programmesTable.add(newProgramme);

      if(addProgrammeResults is error){
        return "Error adding programme: "+ newProgramme.programmeCode + "\n With message: "+addProgrammeResults.message();
      }else {
        return "Programme:" +newProgramme.programmeCode +" Added sucessfully!";
      }
    }
    
    //fetch all course details
    resource function get listProgrammes() returns Programme[] {
      return programmesTable.toArray();
    }

    //update a specific programme by id
    resource function put updateProgrammeByCode( Programme updateProgramme) returns  string{
      error? updateResults = programmesTable.put(updateProgramme);

      if(updateResults is error){
        return "Error updating programme "+ updateProgramme.programmeCode; 
      }else {
        return "Programme "+ updateProgramme.programmeCode + " successfuly updated!"; 
      }
    }

    //retrive details of a specific programme by code
    resource  function get getDetailsOfProgrammeByCode/[string currentProgrammeCode]() returns Programme|error {
        
        //incase we want to acces this resources from another application here is how we can grant permission
        http:Response res = new;
        res.setHeader("Access-Control-Allow-Origin", "http://localhost:51118");
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");

      Programme? programme = programmesTable.get(currentProgrammeCode);

      if(programme is Programme){
        return programme;
      }else {
        return error("Programme with code " + currentProgrammeCode + " not found.");
      }
    }

    //delete a programme by code 
    resource function delete deleteProgramme(string programmeCode) returns string {
        Programme deletedProgramme = programmesTable.remove(programmeCode);
        string errorMessage = "Programme with code " + programmeCode + " deleted successfully.";
         deletedProgramme = programmesTable.get(programmeCode);

        if (deletedProgramme is Programme ) {
             errorMessage = "Error deleting programme: $" + programmeCode;
        } 
        return errorMessage;
    }

        // Retrieve all programmes due that are due
    resource function get programmesDueForReview() returns Programme[] {
        int currentYear = 2024;
        Programme[] dueProgrammes = [];

        foreach var programme in programmesTable {
            int registrationYear = programme.registrationYear;
            if ((currentYear - registrationYear) >= 5) {
                dueProgrammes.push(programme);
            }
        }
        
        return dueProgrammes;
    }

    // Retrieve all programmes by faculty
    resource function get programmesByFaculty(string faculty) returns Programme[] {
        Programme[] programmesInFaculty = [];
        foreach var programme in programmesTable {
            if (programme.faculty == faculty) {
                programmesInFaculty.push(programme);
            }
        }
        return programmesInFaculty;
    }
}
        
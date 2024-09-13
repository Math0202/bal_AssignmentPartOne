import ballerina/http;
import ballerina/time;


type Programme record {|
 readonly string programmeCode;
  int nqfLevel;
  string faculty;
  string department;
  string programmeTitle;
  time:Date registrationDate;
  int programmeLength;
  course[] course;
|};

type course record {|
readonly string courseCode;
 string courseName;
 int nqfLevel;
|};

//create tables to act as the database
table<Programme> key(programmeCode) programmesTable = table[];
table<course> key(courseCode) coursesTable = table[];

service /programmes on new http:Listener(9090) {
    resource function get programmes() returns Programme[]|error {
      Programme hr = {
        programmeCode: "HR612", 
        nqfLevel: 7, 
        faculty: "Human Management",
        department: "Social Study",
        programmeTitle: "HR",
        registrationDate: {year: 2024, month: 6, day: 3},
        programmeLength: 5,
        course: []};
        return [hr];
    }
    
    resource function set .() returns error? {
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
    resource function put updateProgrammeByCode( Programme updateProgramme) returns  string {
      error? updateResults = programmesTable.put(updateProgramme);

      if(updateResults is error){
        return "Error updating programme "+ updateProgramme.programmeCode; 
      }else {
        return "Programme "+ updateProgramme.programmeCode + " successfuly updated!"; 
      }
    }
}

// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

string tempvar = 'Enter_your_name_here';
System.debug('Hello World!');
System.debug('My name is ' + tempvar);

Case c = new Case(Subject = 'SLA test', Priority = 'High');
insert c;
System.debug([SELECT SLA_Due_Date__c, SLA_Status__c, CreatedDate FROM Case WHERE Id = :c.Id]);


Case c1 = [SELECT Id FROM Case WHERE Subject = 'SLA test' LIMIT 1];
c1.Priority = 'Low';
update c1;
System.debug([SELECT SLA_Due_Date__c, SLA_Status__c, CreatedDate FROM Case WHERE Id = :c1.Id]);
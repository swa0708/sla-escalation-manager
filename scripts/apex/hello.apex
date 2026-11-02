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

Case c = new Case(Subject = 'Batch test', Priority = 'High');
insert c;
c.SLA_Due_Date__c = System.now().addHours(-1);
update c;
Database.executeBatch(new SlaCheckBatch());

System.debug([SELECT Subject, SLA_Status__c, IsEscalated FROM Case WHERE Subject = 'Batch test']);
System.debug([SELECT Name, Case__c, Escalation_Type__c, Escalated_On__c FROM Escalation_Log__c]);

System.debug([SELECT Name, Case__c, Escalation_Type__c FROM Escalation_Log__c ORDER BY Name]);

System.schedule('SLA Check Hourly', '0 0 * * * ?', new SlaCheckScheduler());

Case c = new Case(Subject = 'Alert test', Priority = 'High');
insert c;
c.SLA_Due_Date__c = System.now().addHours(-1);
update c;
Database.executeBatch(new SlaCheckBatch());

System.debug([SELECT Name, Case__r.Subject, Escalation_Type__c, Alert_Sent__c FROM Escalation_Log__c WHERE Case__r.Subject = 'Alert test']);
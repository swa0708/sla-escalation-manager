public with sharing class SlaCheckBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, CreatedDate, Priority, SLA_Due_Date__c, SLA_Status__c, IsEscalated
            FROM Case
            WHERE SLA_Due_Date__c != null AND IsClosed = false
        ]);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {
        List<Case> cases = (List<Case>) scope;
        Datetime currentTime = System.now();
        List<Case> casesToUpdate = new List<Case>();
        List<Escalation_Log__c> logs = new List<Escalation_Log__c>();

        for (Case c : cases) {
            SLA_Policy__mdt rule = SlaService.getRule(c.Priority);
            String newStatus;
            if(c.SLA_due_date__c <= currentTime)
            {
                newStatus = 'Breached';
            }
            else
            {
                if((currentTime.getTime() - c.CreatedDate.getTime()) * 100.0 / 
                (c.SLA_Due_Date__c.getTime() - c.CreatedDate.getTime()) >=rule.At_Risk_Percent__c){
                    newStatus = 'At Risk';
                }
            }

            if(newStatus!=null &&  newStatus !=c.SLA_Status__c){
                c.SLA_Status__c = newStatus;
                c.IsEscalated = true;
                casesToUpdate.add(c);

                logs.add(new Escalation_Log__c(
                Case__c = c.Id,
                Escalation_Type__c = newStatus,
                Escalated_On__c = currentTime,
                Alert_Sent__c = false
            ));
        }
    }

    if(!casesToUpdate.isEmpty()){
        update casesToUpdate;
    }

    if(!logs.isEmpty()){
        insert logs;
    }
}
    public void finish(Database.BatchableContext context) {

    }
}
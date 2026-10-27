public with sharing class SlaCheckBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([
            SELECT Id, CreatedDate, Priority, SLA_Due_Date__c, SLA_Status__c, IsEscalated
            FROM Case
            WHERE SLA_Due_Date__c != null AND IsClosed = false
        ]);
    }

    public void execute(Database.BatchableContext context, List<SObject> scope) {

    }

    public void finish(Database.BatchableContext context) {

    }
}
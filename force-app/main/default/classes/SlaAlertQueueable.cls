public with sharing class SlaAlertQueueable implements Queueable {

    private List<Id> logIds;

    public SlaAlertQueueable(List<Id> logIds) {
        this.logIds = logIds;
    }

    public void execute(QueueableContext context) {
       List<Escalation_Log__c> logs = [
            SELECT Id, Alert_Sent__c
            FROM Escalation_Log__c
            WHERE Id IN :logIds
        ];

        for(Escalation_Log__c log : logs){
            log.Alert_Sent__c = true;
        }

        update logs;
    }
}

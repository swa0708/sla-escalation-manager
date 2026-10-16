public with sharing class CaseTriggerHandler {

    public static void beforeInsert(List<Case> newCases) {
        for (Case c : newCases) {
            c.SLA_Due_Date__c = SlaService.calculateDueDate(System.now(), c.Priority);
            c.SLA_Status__c = 'On Track';
        }
    }

    public static void beforeUpdate(List<Case> newCases, Map<Id, Case> oldMap) {
        for (Case c : newCases) {
            Case oldCase = oldMap.get(c.Id);

            // if the priority changed (compare c.Priority with oldCase.Priority):
            //     set c.SLA_Due_Date__c using SlaService, starting from c.CreatedDate
            //     set c.SLA_Status__c to 'On Track'

            if(c.Priority != oldCase.Priority){
                c.SLA_Due_Date__c = SlaService.calculateDueDate(c.CreatedDate, c.Priority);
                c.SLA_Status__c = 'On Track';
            }
        }
    }
}
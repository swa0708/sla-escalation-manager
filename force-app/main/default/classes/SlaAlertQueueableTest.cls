@isTest
private class SlaAlertQueueableTest {

    @isTest
    static void marksAlertAsSent() {
        Case c = new Case(Subject = 'Queueable Test', Priority = 'High');
        insert c;
        Escalation_Log__c log = new Escalation_Log__c(Case__c = c.Id, Escalation_Type__c = 'Breached', Escalated_On__c = System.now(), Alert_Sent__c = false);
        insert log;
        Test.setMock(HttpCalloutMock.class, new SlaWebhookMock(200));
        Test.startTest();
            System.assert(!log.Alert_Sent__c, 'Log should start with Alert_Sent__c false');
            System.enqueueJob(new SlaAlertQueueable(new List<Id>{ log.Id }));
        Test.stopTest();
        Escalation_Log__c saved = [SELECT Alert_Sent__c FROM Escalation_Log__c WHERE Id = :log.Id];
        System.assert(saved.Alert_Sent__c, 'The Queueable should have marked the alert as sent');
    }
}
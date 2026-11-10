@isTest
private class SlaAlertQueueableTest {

    @isTest
    static void marksAlertAsSent() {
        Case c = new Case(Subject = 'Queueable Test', Priority = 'High');
        insert c;
        Escalation_Log__c log = new Escalation_Log__c(Case__c = c.Id, Escalation_Type__c = 'Breached', Escalated_On__c = System.now(), Alert_Sent__c = false);
        insert log;
        Test.setMock(HttpCalloutMock.class, new SlaWebhookMock(200));
        System.assert(!log.Alert_Sent__c, 'Log should start with Alert_Sent__c false');
        Test.startTest();
        System.enqueueJob(new SlaAlertQueueable(new List<Id>{ log.Id }));
        Test.stopTest();
        Escalation_Log__c saved = [SELECT Alert_Sent__c FROM Escalation_Log__c WHERE Id = :log.Id];
        System.assert(saved.Alert_Sent__c, 'The Queueable should have marked the alert as sent');
    }

    @isTest
    static void failedCalloutLeavesAlertUnsent() {
        Case c = new Case(Subject = 'Failed callout test', Priority = 'High');
        insert c;
        Escalation_Log__c log = new Escalation_Log__c(Case__c = c.Id, Escalation_Type__c = 'Breached', Escalated_On__c = System.now(), Alert_Sent__c = false);
        insert log;
        Test.setMock(HttpCalloutMock.class, new SlaWebhookMock(500));
        System.assert(!log.Alert_Sent__c, 'Log should start with Alert_Sent__c false');
        Test.startTest();
        System.enqueueJob(new SlaAlertQueueable(new List<Id>{ log.Id }));
        Test.stopTest();
        Escalation_Log__c saved = [SELECT Alert_Sent__c FROM Escalation_Log__c WHERE Id = :log.Id];
        System.assert(!saved.Alert_Sent__c, 'A failed callout (HTTP 500) must leave Alert_Sent__c false so the alert can be retried');
        //we need to ensure failed call stay retryable because unless and until the callout succeeds we are not sure of the exact status
        // and since it is outside of salesforce environment it is crucial 
    }

    @isTest
    static void exceptionDuringCalloutLeavesAlertUnsent() {
        Case c = new Case(Subject = 'Callout exception test', Priority = 'High');
        insert c;
        Escalation_Log__c log = new Escalation_Log__c(Case__c = c.Id, Escalation_Type__c = 'Breached', Escalated_On__c = System.now(), Alert_Sent__c = false);
        insert log;
        Test.setMock(HttpCalloutMock.class, new SlaWebhookThrowingMock());
        System.assert(!log.Alert_Sent__c, 'Log should start with Alert_Sent__c false');
        Test.startTest();
        System.enqueueJob(new SlaAlertQueueable(new List<Id>{ log.Id }));
        Test.stopTest();
        Escalation_Log__c saved = [SELECT Alert_Sent__c FROM Escalation_Log__c WHERE Id = :log.Id];
        System.assert(!saved.Alert_Sent__c, 'A callout exception must leave Alert_Sent__c false so the alert can be retried');    }

}
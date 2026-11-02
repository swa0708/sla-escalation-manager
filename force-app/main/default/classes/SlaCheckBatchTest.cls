@isTest
private class SlaCheckBatchTest {

    @isTest
    static void pastDueCaseBecomesBreachedAndLogged() {
        Case c = new Case(Subject = 'Breach test', Priority = 'High');
        insert c;
        c.SLA_Due_Date__c = System.now().addHours(-1);
        update c;

        Test.startTest();
        Database.executeBatch(new SlaCheckBatch());
        Test.stopTest();

        Case saved = [SELECT SLA_Status__c, IsEscalated FROM Case WHERE Id = :c.Id];
        List<Escalation_Log__c> logs = [
            SELECT Escalation_Type__c, Alert_Sent__c FROM Escalation_Log__c WHERE Case__c = :c.Id
        ];

        System.assertEquals('Breached', saved.SLA_Status__c, 'Past-due Case should be Breached');
        System.assert(saved.IsEscalated, 'Breached Case should be flagged as escalated');
        System.assertEquals(1, logs.size(), 'Exactly one log row should be written');
        System.assertEquals('Breached', logs[0].Escalation_Type__c, 'Log should record the Breached type');
        System.assert(logs[0].Alert_Sent__c, 'The Queueable should have marked the alert as sent');
    }

    @isTest
    static void atRiskCaseIsEscalated() {

        Case c = new Case(Subject = 'At Risk test', Priority = 'High');
        insert c;
        Test.setCreatedDate(c.id, System.now().addHours(-8));
        c.SLA_Due_Date__c = System.now().addHours(1);
        update c;

        Test.startTest();
        Database.executeBatch(new SlaCheckBatch());
        Test.stopTest();

        Case saved = [SELECT SLA_Status__c, IsEscalated FROM Case WHERE Id = :c.Id];
        List<Escalation_Log__c> logs = [
            SELECT Escalation_Type__c, Alert_Sent__c FROM Escalation_Log__c WHERE Case__c = :c.Id
        ];

        System.assertEquals('At Risk', saved.SLA_Status__c, 'Case with 89% of its time used should be At Risk');        
        System.assert(saved.IsEscalated, 'At Risk Case should be flagged as escalated');
        System.assertEquals(1, logs.size(), 'Exactly one log row should be written');
        System.assertEquals('At Risk', logs[0].Escalation_Type__c, 'Log should record the At Risk type');
        System.assert(logs[0].Alert_Sent__c, 'The Queueable should have marked the alert as sent');

    }
}
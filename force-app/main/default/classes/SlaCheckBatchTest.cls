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

    @isTest
    static void onTrackCaseIsLeftAlone() {

        Case c = new Case(Subject = 'On Track test', Priority = 'High');
        insert c;
        c.SLA_Due_Date__c = System.now().addHours(48);
        update c;

        Test.startTest();
        Database.executeBatch(new SlaCheckBatch());
        Test.stopTest();

        Case saved = [SELECT SLA_Status__c, IsEscalated FROM Case WHERE Id = :c.Id];
        List<Escalation_Log__c> logs = [
            SELECT Escalation_Type__c, Alert_Sent__c FROM Escalation_Log__c WHERE Case__c = :c.Id
        ];

        System.assertEquals('On Track', saved.SLA_Status__c, 'Case with 48 hours time left should be on track');        
        System.assert(!saved.IsEscalated, 'On Track Case should not be flagged as escalated');
        System.assertEquals(0, logs.size(), 'No log row should be written');
    }

    @isTest
    static void closedCaseIsIgnored() {

        Case c = new Case(Subject = 'Closed Case Test', Priority = 'High');
        insert c;
        c.SLA_Due_Date__c = System.now().addHours(-1);
        c.Status = 'Closed';
        update c;

        Test.startTest();
        Database.executeBatch(new SlaCheckBatch());
        Test.stopTest();

        Case saved = [SELECT SLA_Status__c, IsEscalated, IsClosed FROM Case WHERE Id = :c.Id];
        List<Escalation_Log__c> logs = [
            SELECT Escalation_Type__c, Alert_Sent__c FROM Escalation_Log__c WHERE Case__c = :c.Id
        ];

        System.assert(saved.IsClosed, 'Test setup should have closed the Case');
        System.assertEquals('On Track', saved.SLA_Status__c, 'Closed Case should not be touched by the batch');
        System.assert(!saved.IsEscalated, 'Closed Case should not be flagged as escalated');
        System.assertEquals(0, logs.size(), 'No log row should be written');
    }

    @isTest
    static void secondRunCreatesNoDuplicateLogs() {
        Case c = new Case(Subject = 'Second Run test', Priority = 'High');
        insert c;
        c.SLA_Due_Date__c = System.now().addHours(-1);
        update c;

        Test.startTest();
        Database.executeBatch(new SlaCheckBatch());
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
    static void bulkOf200BreachedCases() {

        List<Case> cases = new List<Case>();
        for(integer i=0; i < 200; i++){
            cases.add(new Case(Subject = 'Bulk Test ' + i , Priority = 'High'));

        }

        insert cases;

        for(case c: cases){
            c.SLA_Due_Date__c = System.now().addHours(-1);
        }
        
        update cases;

        Test.startTest();
        Database.executeBatch(new SlaCheckBatch());
        Test.stopTest();

        List<case> saved = [SELECT SLA_Status__c, IsEscalated FROM Case WHERE Id IN :cases];
        List<Escalation_Log__c> logs = [
            SELECT Escalation_Type__c, Alert_Sent__c FROM Escalation_Log__c WHERE Case__c IN :cases
        ];

        System.assertEquals(200, saved.size(), 'All 200 Cases should still exist');
        for (Case c : saved) {
            System.assertEquals('Breached', c.SLA_Status__c, 'Every past-due Case should be Breached');
            System.assert(c.IsEscalated, 'Every Breached Case should be flagged as escalated');
        }

        System.assertEquals(200, logs.size(), 'One log row per Case: 200 expected');
        System.assertEquals('Breached', logs[0].Escalation_Type__c, 'Log should record the Breached type');
        for(Escalation_Log__c log : logs){
            
            System.assert(log.Alert_Sent__c, 'The Queueable should have marked the alert as sent');
        }
    }

}
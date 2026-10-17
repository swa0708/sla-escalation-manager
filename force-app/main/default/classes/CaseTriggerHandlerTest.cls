@isTest
private class CaseTriggerHandlerTest {
    @isTest
    static void insertSetsDueDateAndStatus() {
        Datetime before = System.now();
        Case c = new Case(Subject = 'Test High', Priority = 'High');
        Test.startTest();
        insert c;
        Test.stopTest();
        Case saved = [SELECT SLA_Due_Date__c, SLA_Status__c FROM Case WHERE Id = :c.Id];
        System.assertEquals('On Track', saved.SLA_Status__c, 'New Case should start On Track');
        Long diffMs = Math.abs(saved.SLA_Due_Date__c.getTime() - before.addHours(4).getTime());
        System.assert(diffMs < 5000, 'Due date should be about 4 hours after creation');
    }

    @isTest
    static void priorityChangeRecalculatesFromCreatedDate() {
        Case c = new Case(Subject = 'Test High', Priority = 'High');
        insert c;
        c.Priority= 'Low'; 
        c.SLA_Status__c = 'At Risk';       
        Test.startTest();
        update c;
        Test.stopTest();
         Case updated = [SELECT SLA_Due_Date__c, SLA_Status__c, CreatedDate FROM Case WHERE Id = :c.Id];
         System.assertEquals('On Track', updated.SLA_Status__c, 'Status should be reset to On Track after a priority change');
         System.assertEquals(updated.CreatedDate.addHours(48), updated.SLA_Due_Date__c,
        'Changing High to Low should move the due date to CreatedDate + 48 hours');
    }

    @isTest
    static void nonPriorityEditLeavesDueDateUnchanged() {
        Case c = new Case(Subject = 'Test High', Priority = 'High');
        insert c;
        Case saved = [SELECT SLA_Due_Date__c, SLA_Status__c FROM Case WHERE Id = :c.Id];
        c.Subject = 'Subject'; 
        c.SLA_Status__c = 'At Risk';       
        Test.startTest();
        update c;
        Test.stopTest();
         Case updated = [SELECT SLA_Due_Date__c, SLA_Status__c FROM Case WHERE Id = :c.Id];
         System.assertEquals('At Risk', updated.SLA_Status__c, 'Status should stay At Risk when the priority did not change');
         System.assertEquals(saved.SLA_Due_Date__c, updated.SLA_Due_Date__c,
        'Due date should not change if priority did not change');
    }
}
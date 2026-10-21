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

    @isTest
    static void missingPriorityGetsMediumDeadline() {

        Datetime before = System.now();
        Case c = new Case(Subject = 'Test no priority');
        Test.startTest();
        insert c;
        Test.stopTest();
        Case saved = [SELECT SLA_Due_Date__c, SLA_Status__c, priority FROM Case WHERE Id = :c.Id];
        System.assertEquals('On Track', saved.SLA_Status__c, 'Case with no priority should still start On Track');
        System.debug(saved.Priority);
        Long diffMs = Math.abs(saved.SLA_Due_Date__c.getTime() - before.addHours(24).getTime());
        System.assert(diffMs < 5000, 'Case with no priority should get the Medium deadline (24 hours)');
    }

@isTest
static void bulkInsertOf200Cases() {
    List<String> priorities = new List<String>{ 'High', 'Medium', 'Low' };
    List<Case> cases = new List<Case>();

    for (Integer i = 0; i < 200; i++) {
        cases.add(new Case(Subject = 'Bulk ' + i, Priority = priorities.get(Math.mod(i, 3))));
    }

    Test.startTest();
    insert cases;
    Test.stopTest();

    List<Case> saved = [SELECT SLA_Due_Date__c, SLA_Status__c FROM Case WHERE Id IN :cases];
    System.assertEquals(200, saved.size(), 'All 200 Cases should be saved');
    for (Case c : saved) {
        System.assertEquals('On Track', c.SLA_Status__c, 'Every bulk Case should start On Track');
        System.assertNotEquals(null, c.SLA_Due_Date__c, 'Every bulk Case should get a due date');
    }
}
}
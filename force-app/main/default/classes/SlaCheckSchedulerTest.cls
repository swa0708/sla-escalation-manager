@isTest
private class SlaCheckSchedulerTest {

    @isTest
    static void schedulesTheHourlyJob() {
        
        String cron = '0 0 * * * ?';
        Id jobId;

        Test.startTest();
        jobId = System.schedule('Test SLA job', cron, new SlaCheckScheduler());
        Test.stopTest();

        CronTrigger cronJob = [SELECT CronExpression, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        System.assertNotEquals(null, cronJob.NextFireTime, 'Job should be scheduled to run');
        System.assertEquals(cron, cronJob.CronExpression, 'cron an cron expression should match');
    }
}
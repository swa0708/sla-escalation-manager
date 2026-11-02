public with sharing class SlaCheckScheduler implements Schedulable {

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SlaCheckBatch());
    }
}

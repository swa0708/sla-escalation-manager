public with sharing class SlaService {
    public static Datetime calculateDueDate(Datetime startTime, String priority) {
        SLA_Policy__mdt rule = getRule(priority);
        // 3. Add the rule's hours to the start time
        return startTime.addHours(rule.SLA_Hours__c.intValue());
    }

    public static SLA_Policy__mdt getRule(String priority) {
        // 1. Look up the rule only when a priority was given
        SLA_Policy__mdt rule;
        if (priority != null) {
            rule = SLA_Policy__mdt.getInstance(priority);
        }

        // 2. No priority, or no matching rule: fall back to Medium
        if (rule == null) {
            rule = SLA_Policy__mdt.getInstance('Medium');
        }
        return rule;
    }
}


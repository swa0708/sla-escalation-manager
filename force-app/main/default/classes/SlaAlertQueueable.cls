public with sharing class SlaAlertQueueable implements Queueable, Database.AllowsCallouts {

    private List<Id> logIds;

    public SlaAlertQueueable(List<Id> logIds) {
        this.logIds = logIds;
    }

    public void execute(QueueableContext context) {
       List<Escalation_Log__c> logs = [
            SELECT Id, Name, Escalation_Type__c, Case__r.CaseNumber, Case__r.Subject, Alert_Sent__c
            FROM Escalation_Log__c
            WHERE Id IN :logIds
        ];

        List<Map<String, Object>> payload = new List<Map<String, Object>>();
        for(Escalation_Log__c log : logs){
            Map<String, Object> item = new Map<String, Object>();
            item.put('log', log.Name);
            item.put('type', log.Escalation_Type__c);
            item.put('caseNumber', log.Case__r.CaseNumber);
            item.put('subject', log.Case__r.Subject);
            payload.add(item);            
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SLA_Webhook');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize(payload));
        HttpResponse res;
        try {
            res = new Http().send(req);
        } catch (CalloutException e) {
                    System.debug(LoggingLevel.ERROR, 'Alert callout failed: ' + e.getMessage());
                    return;
        }
        if (res.getStatusCode() >= 200 && res.getStatusCode() <= 299) {
            for (Escalation_Log__c log : logs) {
                log.Alert_Sent__c = true;
            }
            update logs;
        }
    }
}

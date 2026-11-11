@RestResource(urlMapping='/sla/cases/*')
global with sharing class SlaCaseApi {

    @HttpPost
    global static void createCase(String subject, String priority, String description) {
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        if(String.isBlank(subject)){
            respond(res, 400, new Map<String, Object>{
                'status' => 400,
                'message' => 'Invalid request: "subject" is required and cannot be blank'
            });
             return;
        }

        Set<String> validPriorities = new Set<String>{ 'High', 'Medium', 'Low' };
        if (priority != null && !validPriorities.contains(priority)) {
            respond(res, 400, new Map<String, Object>{
                'status' => 400,
                'message' => 'Invalid request: "priority" must be High, Medium or Low (case-sensitive), or omitted'
            });
            return;
        }

        Case newCase = new Case(Subject = subject, Priority = priority, Description = description);

        try {
            insert newCase;
        } catch (DmlException e) {
            respond(res, 500, new Map<String, Object>{
                'status' => 500,
                'message' => 'Could not create the Case'
            });
            return;
        }

        List<Case> saved = [SELECT CaseNumber, SLA_Due_Date__c FROM Case WHERE Id = :newCase.Id];
        Case created = saved[0];
        respond(res, 201, new Map<String, Object>{
            'status' => 201,
            'id' => created.Id,
            'caseNumber' => created.CaseNumber,
            'slaDueDate' => created.SLA_Due_Date__c
        });
    }

    private static void respond(RestResponse res, Integer code, Map<String, Object> body) {
        res.statusCode = code;
        res.responseBody = Blob.valueOf(JSON.serialize(body));
    }
}
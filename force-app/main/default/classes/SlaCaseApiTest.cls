@IsTest
private class SlaCaseApiTest {

    private static RestResponse callApi(String subject, String priority) {
        RestRequest req = new RestRequest();
        req.requestURI = '/services/apexrest/sla/cases';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        SlaCaseApi.createCase(subject, priority, null);
        return RestContext.response;
    }

    @IsTest
    static void validRequestCreatesCase() {
        
        RestResponse res = callApi('Printer down', 'High');
        System.assertEquals(201, res.statusCode, 'A valid request should return HTTP 201');
        Map<String, Object> body = (Map<String, Object>) JSON.deserializeUntyped(res.responseBody.toString());
        System.assertNotEquals(null, body.get('caseNumber'), 'Response should include the new case number');        
        String caseNumber = (String) body.get('caseNumber');
        Case saved = [SELECT Subject, SLA_Due_Date__c FROM Case WHERE CaseNumber = :caseNumber];
        System.assertEquals('Printer down', saved.Subject, 'The saved Case should carry the requested subject');
        System.assertNotEquals(null, saved.SLA_Due_Date__c, 'The trigger should have stamped an SLA due date');        
    }
}
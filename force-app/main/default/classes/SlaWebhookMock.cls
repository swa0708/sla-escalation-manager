@IsTest
public class SlaWebhookMock implements HttpCalloutMock {

    private Integer statusCode;

    public SlaWebhookMock(Integer statusCode) {
        this.statusCode = statusCode;
    }

    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody('{"ok": true}');
        return res;
    }
}
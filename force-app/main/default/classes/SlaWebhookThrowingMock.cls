@IsTest
public class SlaWebhookThrowingMock implements HttpCalloutMock {

    public HttpResponse respond(HttpRequest req) {
        CalloutException ex = new CalloutException();
        ex.setMessage('Simulated timeout');
        throw ex;
    }
}


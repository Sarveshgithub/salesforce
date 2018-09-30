public class cls_CurrencyConverter {
	@AuraEnabled
    public static String calloutCurrency() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://www.apilayer.net/api/live?access_key=27f9066b2e5a0674318ea16a523a0fd6&format=1');
        req.setMethod('GET'); 
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());
        return res.getBody();
    }
}
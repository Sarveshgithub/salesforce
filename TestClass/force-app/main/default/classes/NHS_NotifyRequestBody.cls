public class NHS_NotifyRequestBody {
    @AuraEnabled @InvocableVariable public String notification_type;
	@AuraEnabled @InvocableVariable public String email_address;
    @AuraEnabled @InvocableVariable public String phone_number;
	@AuraEnabled @InvocableVariable public String template_id;	
    @AuraEnabled @InvocableVariable public String reference;
}
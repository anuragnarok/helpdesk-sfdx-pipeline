public class HelpdeskTicketService {
    @InvocableMethod(Label='create' description='Action method to create ticket')
    public static list<OuterWrapper> createTicket(List<InsertWrapper> requests){
        List<Helpdesk_Ticket__c> htList = new list<Helpdesk_Ticket__c>();
        for(InsertWrapper iw: requests){
            Helpdesk_Ticket__c ht = new Helpdesk_Ticket__c();
            ht.Subject__c = iw.Subject;
            ht.Category__c = iw.Category;
            ht.Description__c = iw.description;
             ht.Employee__c = UserInfo.getUserId();
            htList.add(ht);
        }
        if(!htList.isEmpty()){
            insert htList;
        }
        List<OuterWrapper> results = new list<OuterWrapper>();
        for(Helpdesk_Ticket__c ht : htList){
            OuterWrapper Ow = new OuterWrapper();
            Ow.Name =ht.Name;
            Ow.Id= ht.Id;
            results.add(Ow);
        }
        return results;
    }
    
    public class InsertWrapper{
       	 @InvocableVariable
        public String Subject; 
         @InvocableVariable
        public String Description;
         @InvocableVariable
        public String Category;
        
    }
    
     public class OuterWrapper{
        @InvocableVariable
        public String Name; 
        @InvocableVariable
        public String Id;
        
    }
    

}
@isTest
private class HelpdeskTicketTriggerHandlerTest {

    @testSetup
static void setup() {
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Helpdesk_Ticket_Access' LIMIT 1];
    insert new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
}

    @isTest
    static void singleInsert() {
       Helpdesk_Ticket__c ht = new Helpdesk_Ticket__c();
        String currentUser = UserInfo.getUserId();

        ht.Category__c = 'Software';
        ht.Employee__c = currentUser;

        Test.startTest();
        Insert ht;
        Test.stopTest();
        Helpdesk_Ticket__c htP = [Select priority__c from Helpdesk_Ticket__c WHERE Employee__c =:currentUser  LIMIT 1];
		Assert.areEqual('Medium',htP.Priority__c);

    }

    @isTest
    static void bulkTest(){
        List<Helpdesk_Ticket__c> htList = new list<Helpdesk_Ticket__c>();
        for(Integer i=0;i<100;i++){
            Helpdesk_Ticket__c ht = new Helpdesk_Ticket__c();
            ht.Category__c = 'Software';
            ht.Employee__c = UserInfo.getUserId();
            htList.add(ht);
        }
        for(Integer i=0;i<100;i++){
            Helpdesk_Ticket__c ht = new Helpdesk_Ticket__c();
            ht.Category__c = 'Hardware';
            ht.Employee__c = UserInfo.getUserId();
            htList.add(ht);
        }
        if(!htList.isEmpty()){
            Test.StartTest();
            insert htList;
            Test.StopTest();
        }
        Integer htCount = [Select Count() from Helpdesk_Ticket__c where Employee__c =:UserInfo.getUserId() ];
         Helpdesk_Ticket__c htP1 = [Select priority__c from Helpdesk_Ticket__c WHERE Employee__c =:UserInfo.getUserId() AND category__c='Hardware'  LIMIT 1];
         Helpdesk_Ticket__c htP2 = [Select priority__c from Helpdesk_Ticket__c WHERE Employee__c =:UserInfo.getUserId() AND category__c='Software'  LIMIT 1];
        Assert.areEqual(200,htCount);
        Assert.areEqual('High',htP1.Priority__c);
        Assert.areEqual('Medium',htP2.Priority__c);

    }

    @isTest
    static void negativeTest(){
        Helpdesk_Ticket__c ht = new Helpdesk_Ticket__c();
        ht.Category__c ='mobile';
        ht.Employee__c = UserInfo.getUserId();
        String err = '';
        try{
            insert ht;
        }catch(HelpdeskTicketTriggerHandler.InvalidCategoryException e){
           err = 'Error Detected';
        }
        Assert.areEqual('Error Detected', err);

    }
}
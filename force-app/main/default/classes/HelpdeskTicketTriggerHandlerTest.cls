@isTest
private class HelpdeskTicketTriggerHandlerTest {

@testSetup
static void setup() {
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    User u = new User(
        Alias = 'htuser', Email = 'htuser@example.com', EmailEncodingKey = 'UTF-8',
        LastName = 'Tester', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US',
        ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles',
        UserName = 'htuser' + System.currentTimeMillis() + '@helpdeskdevops.test'
    );
    insert u;
    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Helpdesk_Ticket_Access' LIMIT 1];
    insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);
}

private static User getTestUser() {
    return [SELECT Id FROM User WHERE Alias = 'htuser' ORDER BY CreatedDate DESC LIMIT 1];
}

@isTest
static void singleInsert() {
    User u = getTestUser();
    System.runAs(u) {
        Helpdesk_Ticket__c ht = new Helpdesk_Ticket__c(Category__c = 'Software', Employee__c = u.Id);
        Test.startTest();
        insert ht;
        Test.stopTest();
        Helpdesk_Ticket__c htP = [SELECT Priority__c FROM Helpdesk_Ticket__c WHERE Employee__c = :u.Id LIMIT 1];
        Assert.areEqual('Medium', htP.Priority__c);
    }
}

@isTest
static void bulkTest() {
    User u = getTestUser();
    System.runAs(u) {
        List<Helpdesk_Ticket__c> htList = new List<Helpdesk_Ticket__c>();
        for (Integer i = 0; i < 100; i++) {
            htList.add(new Helpdesk_Ticket__c(Category__c = 'Software', Employee__c = u.Id));
        }
        for (Integer i = 0; i < 100; i++) {
            htList.add(new Helpdesk_Ticket__c(Category__c = 'Hardware', Employee__c = u.Id));
        }
        Test.startTest();
        insert htList;
        Test.stopTest();
        Integer htCount = [SELECT COUNT() FROM Helpdesk_Ticket__c WHERE Employee__c = :u.Id];
        Helpdesk_Ticket__c htP1 = [SELECT Priority__c FROM Helpdesk_Ticket__c WHERE Employee__c = :u.Id AND Category__c = 'Hardware' LIMIT 1];
        Helpdesk_Ticket__c htP2 = [SELECT Priority__c FROM Helpdesk_Ticket__c WHERE Employee__c = :u.Id AND Category__c = 'Software' LIMIT 1];
        Assert.areEqual(200, htCount);
        Assert.areEqual('High', htP1.Priority__c);
        Assert.areEqual('Medium', htP2.Priority__c);
    }
}

@isTest
static void negativeTest() {
User u = getTestUser();
System.runAs(u) {
    // blank category is the only value that reaches the 'when else' branch
    Helpdesk_Ticket__c ht = new Helpdesk_Ticket__c(Employee__c = u.Id);
    String err = '';
    try {
        insert ht;
    } catch (DmlException e) {
        err = e.getMessage();
    }
    Assert.isTrue(err.contains('is not a valid value'), 'Unexpected message: ' + err);
}
}

@isTest
static void accessAndOtherCategories() {
    User u = getTestUser();
    System.runAs(u) {
        Helpdesk_Ticket__c a = new Helpdesk_Ticket__c(Category__c = 'Access', Employee__c = u.Id);
        Helpdesk_Ticket__c o = new Helpdesk_Ticket__c(Category__c = 'Other', Employee__c = u.Id);
        insert new List<Helpdesk_Ticket__c>{a, o};
        Assert.areEqual('High', [SELECT Priority__c FROM Helpdesk_Ticket__c WHERE Id = :a.Id].Priority__c);
        Assert.areEqual('Low', [SELECT Priority__c FROM Helpdesk_Ticket__c WHERE Id = :o.Id].Priority__c);
    }
}

@isTest
static void serviceCreatesTicket() {
    User u = getTestUser();
    System.runAs(u) {
        HelpdeskTicketService.InsertWrapper iw = new HelpdeskTicketService.InsertWrapper();
        iw.Subject = 'Laptop screen cracked';
        iw.Category = 'Hardware';
        iw.Description = 'Screen cracked after a fall';
        Test.startTest();
        List<HelpdeskTicketService.OuterWrapper> res =
            HelpdeskTicketService.createTicket(new List<HelpdeskTicketService.InsertWrapper>{iw});
        Test.stopTest();
        Assert.areEqual(1, res.size());
        Assert.isNotNull(res[0].Id);
    }
}
}
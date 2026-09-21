trigger HelpdeskTicketTrigger on Helpdesk_Ticket__c (before insert) {
	HelpdeskTicketTriggerHandler.setPriorityOnInsert(trigger.new);
}
public class HelpdeskTicketTriggerHandler {
    public static void setPriorityOnInsert(List<Helpdesk_Ticket__c> newTickets){
        for(Helpdesk_Ticket__c rec : newtickets){
            Switch on rec.Category__c{
                when 'Access'{
                    rec.Priority__c = 'High';
                }
                when 'Hardware'{
                    rec.Priority__c ='High';
                }
                when 'Software'{
                    rec.Priority__c = 'Medium';
                }
                when 'Other'{
                    rec.Priority__c = 'Low';
                }
                when else {
                    throw new InvalidCategoryException('Category ='+rec.Category__c+' is not a valid value. Ticket userId ='+rec.Employee__c);
                }
            }
            
        }
    }
    
    public class InvalidCategoryException extends Exception {}

}
public class OpportunityDeleteService {
	@AuraEnabled
    public static void deleteOpportunities(List<Id> opportunityIds){
        List<Opportunity> oppToDelete = [SELECT Id FROM Opportunity 
                                         WHERE Id IN :opportunityIds];
        
        delete oppToDelete;
    }
}
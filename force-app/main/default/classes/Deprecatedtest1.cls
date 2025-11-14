public class Deprecatedtest1 {
// Deprecatedtest1.addFinicityPermissionSetToUser();
    public static Set<Id> addFinicityPermissionSetToUser(){

            //LLC_BI__Enable_Exclude__c
 //Loans = [SELECT Id, LLC_BI__Account__c,LLC_BI__Comments__c,LLC_BI__Debt__c FROM LLC_BI__Enable_Exclude__c
 //WHERE Name like 'A%'];

        Set<Id> LoanIdSets = new Set<Id>();

        System.debug('InaddFinicityPermissionSetTo');
        Set<Id> val;
        return LoanIdSets ?? (val = new Set<Id>());

  }

}
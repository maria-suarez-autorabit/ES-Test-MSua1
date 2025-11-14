trigger LoanTrigger2 on Loan_c__c (before update) {
    List<Loan_c__c> loans = [SELECT Id, Name FROM Loan_c__c]; // SOQL inside loop (bad practice)
    
    for (Loan_c__c loan : loans) {
        loan.Name = 'Updated Name'; 
        update loan; // Performing DML within loop (bad practice)
    }
}
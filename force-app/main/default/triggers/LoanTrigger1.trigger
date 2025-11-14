trigger LoanTrigger1 on Loan_c__c (before insert) {
    for (Loan_c__c loan : Trigger.new) {
        loan.Name = loan.Name + ' - Violating Best Practices';
    }
}
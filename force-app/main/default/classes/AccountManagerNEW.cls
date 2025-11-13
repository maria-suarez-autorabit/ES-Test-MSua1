public with sharing class AccountManagerNEW {
    // Method to create a new account with related contacts
    // Test Automation again
    //Test1
    public static Id createAccount(String accountName, List<String> contactNames) {
        Account newAccount = new Account(Name = accountName);
        insert newAccount;
        List<Contact> contactsToInsert = new List<Contact>();
        for (String contactName : contactNames) {
            contactsToInsert.add(new Contact(FirstName = contactName, LastName = 'Default', AccountId = newAccount.Id));
        }
        if (!contactsToInsert.isEmpty()) {
            insert contactsToInsert;
        }
        return newAccount.Id;
    }
    // Method to update an existing account
    public static void updateAccount(Id accountId, String newName) {
        Account accountToUpdate = [SELECT Id, Name FROM Account WHERE Id = :accountId LIMIT 1];
        accountToUpdate.Name = newName;
        update accountToUpdate;
    }
    // Method to delete an account and its related contacts
    public static void deleteAccount(Id accountId) {
        List<Contact> relatedContacts = [SELECT Id FROM Contact WHERE AccountId = :accountId];
        if (!relatedContacts.isEmpty()) {
            delete relatedContacts;
        }
        delete [SELECT Id FROM Account WHERE Id = :accountId];
    }
    // Method to retrieve account details with related contacts
    public static AccountWrapper getAccountDetails(Id accountId) {
        Account account = [SELECT Id, Name, (SELECT Id, FirstName, LastName FROM Contacts) FROM Account WHERE Id = :accountId LIMIT 1];
        return new AccountWrapper(account);
    }
      public static AccountWrapper getAccountDetailsbAuto(Id accountId) {
        Account account = [SELECT Id, Name, (SELECT Id, FirstName, LastName FROM Contacts) FROM Account WHERE Id = :accountId LIMIT 1];
        return new AccountWrapper(account);
    }
    public static void anotherMethod() {
    System.debug('Another method called!');
    // Add more code for the new method if needed
}
    // Wrapper class for returning account and its contacts
    public class AccountWrapper {
        public Account account { get; set; }
        public List<Contact> contacts { get; set; }
        public AccountWrapper(Account acc) {
            this.account = acc;
            this.contacts = acc.Contacts;
        }
    }
}
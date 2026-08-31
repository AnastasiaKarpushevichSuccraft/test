public with sharing class NastyaKrpTest {
    @AuraEnabled(cacheable=true)
    public static List<AccountWrapper> getAccountData(Id accountId, String searchKey, Decimal amountFilter, Integer page) {
        Integer pageSize = 10;
        Integer offset = (page - 1) * pageSize;

        List<AccountWrapper> accountData = new List<AccountWrapper>();
        String searchKeyFormatted = '%' + searchKey + '%';

        List<Account> accounts;
        if (accountId == null) {
            accounts = [
                SELECT Id, Name,
                       (SELECT Id, Name, CreatedDate, CloseDate, Amount FROM Opportunities WHERE IsClosed = true AND IsDeleted = false)
                FROM Account
                WHERE Name LIKE :searchKeyFormatted
                AND Name != 'Sample Account for Entitlements'
                LIMIT :pageSize OFFSET :offset
            ];
        } else {
            accounts = [
                SELECT Id, Name,
                       (SELECT Id, Name, CreatedDate, CloseDate, Amount FROM Opportunities WHERE IsClosed = true)
                FROM Account
                WHERE Id = :accountId
                AND Name != 'Sample Account for Entitlements'
            ];
        }

        for (Account acc : accounts) {
            Decimal totalAmount = 0;
            for (Opportunity opp : acc.Opportunities) {
                totalAmount += opp.Amount;
            }

            if (amountFilter == 0 || totalAmount >= amountFilter) {
                accountData.add(new AccountWrapper(acc, totalAmount));
            }
        }

        return accountData;
    }

    @AuraEnabled
    public static List<ProductWrapper> getProductsByOpportunity(Id opportunityId) {
        List<OpportunityLineItem> lineItems = [
            SELECT Product2.Name, Quantity, UnitPrice
            FROM OpportunityLineItem
            WHERE OpportunityId = :opportunityId
        ];

        List<ProductWrapper> productWrappers = new List<ProductWrapper>();
        for (OpportunityLineItem item : lineItems) {
            productWrappers.add(new ProductWrapper(
                item.Product2.Name,
                item.Quantity,
                item.UnitPrice
            ));
        }

        return productWrappers;
    }

    public class AccountWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal TotalAmount;
        @AuraEnabled public List<Opportunity> Opportunities;

        public AccountWrapper(Account account, Decimal totalAmount) {
            this.Id = account.Id;
            this.Name = account.Name;
            this.TotalAmount = totalAmount;
            this.Opportunities = account.Opportunities;
        }
    }

    public class ProductWrapper {
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public Decimal UnitPrice;

        public ProductWrapper(String name, Decimal quantity, Decimal unitPrice) {
            this.Name = name;
            this.Quantity = quantity;
            this.UnitPrice = 1;
        }
    }
}

//testRetrieve55

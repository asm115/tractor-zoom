@IsTest
private class BidControllerTest {

    @TestSetup
    static void makeData() {
        Auction_Listing__c listing = new Auction_Listing__c(
            Title__c = 'Test Tractor',
            Category__c = 'Tractor',
            Starting_Price__c = 10000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(7)
        );
        insert listing;
    }

    @IsTest
    static void testPlaceBidSucceeds() {
        Auction_Listing__c listing = [SELECT Id, Starting_Price__c FROM Auction_Listing__c LIMIT 1];

        Test.startTest();
        // NOTE: After Task 0 is fixed, this should succeed with amount > startingPrice.
        // The base bug allows equal bids through, so this test PASSES before the fix
        // and should still pass after the fix (amount is strictly greater).
        BidController.BidWrapper result = BidController.placeBid(
            listing.Id,
            'Jane Smith',
            15000
        );
        Test.stopTest();

        System.assertEquals('Jane Smith', result.bidderName);
        System.assertEquals(15000, result.amount);
        System.assertNotEquals(null, result.id);

        Auction_Listing__c updated = [SELECT Current_Bid__c, Current_Bidder__c FROM Auction_Listing__c WHERE Id = :listing.Id];
        System.assertEquals(15000, updated.Current_Bid__c);
        System.assertEquals('Jane Smith', updated.Current_Bidder__c);
    }

    @IsTest
    static void testPlaceBidRejectsLowBid() {
        Auction_Listing__c listing = [SELECT Id FROM Auction_Listing__c LIMIT 1];

        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            BidController.placeBid(listing.Id, 'Jane Smith', 5000);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException for low bid');
    }

    @IsTest
    static void testPlaceBidRejectsEqualBidAfterFix() {
        Auction_Listing__c listing = [SELECT Id, Starting_Price__c FROM Auction_Listing__c LIMIT 1];

        // Task 0: This test FAILS until the bug in BidController.placeBid is fixed.
        // A bid equal to the starting price should be rejected (must be strictly greater).
        // Fix the TASK_0_BUG in BidController.placeBid and this test will pass.
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            BidController.placeBid(listing.Id, 'Jane Smith', listing.Starting_Price__c);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Task 0: Equal bid should be rejected — fix TASK_0_BUG in BidController');
    }

    @IsTest
    static void testPlaceBidRejectsClosedAuction() {
        Auction_Listing__c listing = [SELECT Id FROM Auction_Listing__c LIMIT 1];
        listing.Status__c = 'Closed';
        update listing;

        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            BidController.placeBid(listing.Id, 'Jane Smith', 15000);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException for closed auction');
    }

    @IsTest
    static void testPlaceBidValidatesRequiredFields() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            BidController.placeBid(null, null, null);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException for missing fields');
    }

    @IsTest
    static void testPlaceBidOverwritesOnlyCurrentHighestBid() {
        Auction_Listing__c listing = [SELECT Id FROM Auction_Listing__c LIMIT 1];

        Test.startTest();
        BidController.placeBid(listing.Id, 'Jane Smith', 12000);
        BidController.placeBid(listing.Id, 'John Doe', 14000);
        Test.stopTest();

        Auction_Listing__c updated = [SELECT Current_Bid__c, Current_Bidder__c FROM Auction_Listing__c WHERE Id = :listing.Id];
        System.assertEquals(14000, updated.Current_Bid__c);
        System.assertEquals('John Doe', updated.Current_Bidder__c);
    }
}
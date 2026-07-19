@IsTest
private class AuctionListingControllerTest {

    @TestSetup
    static void makeData() {
        List<Auction_Listing__c> listings = new List<Auction_Listing__c>{
            new Auction_Listing__c(
                Title__c = 'John Deere 8R Tractor',
                Description__c = 'Well-maintained 2020 model',
                Category__c = 'Tractor',
                Starting_Price__c = 85000,
                Status__c = 'Active',
                Ends_At__c = System.now().addDays(7)
            ),
            new Auction_Listing__c(
                Title__c = 'Case IH Combine',
                Description__c = 'Ready for harvest season',
                Category__c = 'Combine',
                Starting_Price__c = 220000,
                Status__c = 'Active',
                Ends_At__c = System.now().addDays(3)
            ),
            new Auction_Listing__c(
                Title__c = 'Closed Auction',
                Description__c = 'Already ended',
                Category__c = 'Implement',
                Starting_Price__c = 5000,
                Status__c = 'Closed',
                Ends_At__c = System.now().addDays(-1)
            )
        };
        insert listings;
    }

    @IsTest
    static void testGetListingsReturnsAllListings() {
        Test.startTest();
        AuctionListingController.ListingsResult result = AuctionListingController.getListings();
        Test.stopTest();

        System.assertEquals(3, result.listings.size(), 'Should return all listings, including closed');
    }

    @IsTest
    static void testGetListingReturnsCorrectRecord() {
        Auction_Listing__c listing = [SELECT Id FROM Auction_Listing__c WHERE Title__c = 'John Deere 8R Tractor' LIMIT 1];

        Test.startTest();
        AuctionListingController.ListingWrapper result = AuctionListingController.getListing(listing.Id);
        Test.stopTest();

        System.assertEquals('John Deere 8R Tractor', result.title);
        System.assertEquals('Tractor', result.category);
        System.assertEquals(85000, result.startingPrice);
        System.assertEquals('Active', result.status);
    }

    @IsTest
    static void testGetListingThrowsForNonExistentId() {
        // Insert a record, capture its ID, then delete it so the ID is valid-format but non-existent.
        Auction_Listing__c temp = new Auction_Listing__c(
            Title__c = 'Temp', Category__c = 'Tractor', Starting_Price__c = 1000,
            Status__c = 'Active', Ends_At__c = System.now().addDays(1)
        );
        insert temp;
        String deletedId = temp.Id;
        delete temp;

        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            AuctionListingController.getListing(deletedId);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException for non-existent listing ID');
    }

    @IsTest
    static void testCreateListingInsertsRecord() {
        Test.startTest();
        String newId = AuctionListingController.createListing(
            'New Grain Cart',
            'Excellent condition',
            'Implement',
            12000,
            '2026-12-01T00:00:00Z',
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, newId, 'Should return a new record ID');
        Auction_Listing__c created = [SELECT Title__c, Status__c FROM Auction_Listing__c WHERE Id = :newId];
        System.assertEquals('New Grain Cart', created.Title__c);
        System.assertEquals('Active', created.Status__c);
    }

    @IsTest
    static void testCreateListingValidatesRequiredFields() {
        Boolean exceptionThrown = false;
        try {
            Test.startTest();
            AuctionListingController.createListing(null, null, null, null, null, null);
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected AuraHandledException for missing required fields');
    }
}
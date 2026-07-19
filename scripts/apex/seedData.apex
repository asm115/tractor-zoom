// Seed data for TractorZoom Farm Auction take-home
// Run with: sf apex run --file scripts/apex/seedData.apex --target-org FarmAuction

if ([SELECT COUNT() FROM Auction_Listing__c] > 0) {
    System.debug('Seed data already present — skipping.');
} else {
    List<Auction_Listing__c> listings = new List<Auction_Listing__c>{
        new Auction_Listing__c(
            Title__c = 'John Deere 8R 410 Tractor',
            Category__c = 'Tractor',
            Starting_Price__c = 285000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(7)
        ),
        new Auction_Listing__c(
            Title__c = 'Case IH 9250 Axial-Flow Combine',
            Category__c = 'Combine',
            Starting_Price__c = 320000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(5)
        ),
        new Auction_Listing__c(
            Title__c = 'Kinze 1051 Grain Cart',
            Category__c = 'Implement',
            Starting_Price__c = 48000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(10)
        ),
        new Auction_Listing__c(
            Title__c = 'Bobcat S770 Skid Steer',
            Category__c = 'Implement',
            Starting_Price__c = 52000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(4)
        ),
        new Auction_Listing__c(
            Title__c = 'New Holland T8.435 Tractor',
            Category__c = 'Tractor',
            Starting_Price__c = 340000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(14)
        ),
        new Auction_Listing__c(
            Title__c = 'John Deere 7000 Planter — 24 Row',
            Category__c = 'Implement',
            Starting_Price__c = 28000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(3)
        ),
        new Auction_Listing__c(
            Title__c = 'Fendt 942 Vario Tractor',
            Category__c = 'Tractor',
            Starting_Price__c = 410000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(9)
        ),
        new Auction_Listing__c(
            Title__c = 'Gleaner S98 Combine',
            Category__c = 'Combine',
            Starting_Price__c = 195000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(6)
        ),
        new Auction_Listing__c(
            Title__c = 'Agco Allis 9650 Tractor',
            Category__c = 'Tractor',
            Starting_Price__c = 15000,
            Status__c = 'Active',
            Ends_At__c = System.now().addDays(2)
        )
    };
    insert listings;
    System.debug('Seeded ' + listings.size() + ' auction listings.');
}

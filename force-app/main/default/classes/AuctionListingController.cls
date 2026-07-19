public with sharing class AuctionListingController {

    public class ListingWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String title { get; set; }
        @AuraEnabled public String description { get; set; }
        @AuraEnabled public String category { get; set; }
        @AuraEnabled public Decimal startingPrice { get; set; }
        @AuraEnabled public Decimal currentBid { get; set; }
        @AuraEnabled public String currentBidder { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String endsAt { get; set; }
        @AuraEnabled public String imageUrl { get; set; }
    }

    public class ListingsResult {
        @AuraEnabled public List<ListingWrapper> listings { get; set; }
    }

    @AuraEnabled
    public static ListingsResult getListings() {
        List<Auction_Listing__c> listings = Database.query(
            'SELECT Id, Title__c, Description__c, Category__c, ' +
            'Starting_Price__c, Current_Bid__c, Current_Bidder__c, ' +
            'Status__c, Ends_At__c, Image_URL__c ' +
            'FROM Auction_Listing__c ORDER BY Ends_At__c ASC'
        );

        ListingsResult result = new ListingsResult();
        result.listings = new List<ListingWrapper>();

        for (Auction_Listing__c l : listings) {
            result.listings.add(toWrapper(l));
        }
        return result;
    }

    @AuraEnabled
    public static ListingWrapper getListing(String listingId) {
        try {
            Auction_Listing__c listing = [
                SELECT Id, Title__c, Description__c, Category__c,
                       Starting_Price__c, Current_Bid__c, Current_Bidder__c,
                       Status__c, Ends_At__c, Image_URL__c
                FROM Auction_Listing__c
                WHERE Id = :listingId
                LIMIT 1
            ];
            return toWrapper(listing);
        } catch (Exception e) {
            throw new AuraHandledException('Listing not found: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String createListing(
        String title,
        String description,
        String category,
        Decimal startingPrice,
        String endsAt,
        String imageUrl
    ) {
        if (String.isBlank(title) || String.isBlank(category) || startingPrice == null || String.isBlank(endsAt)) {
            throw new AuraHandledException('Title, category, starting price, and end date are required.');
        }
        if (!Auction_Listing__c.sObjectType.getDescribe().isCreateable()) {
            throw new AuraHandledException('Insufficient permissions to create listings.');
        }
        try {
            String normalizedEndsAt = endsAt.replace('T', ' ').removeEnd('Z').left(19);
            if (normalizedEndsAt.length() == 16) normalizedEndsAt += ':00';
            Auction_Listing__c listing = new Auction_Listing__c(
                Title__c = title,
                Description__c = description,
                Category__c = category,
                Starting_Price__c = startingPrice,
                Current_Bid__c = null,
                Current_Bidder__c = null,
                Status__c = 'Active',
                Ends_At__c = DateTime.valueOfGmt(normalizedEndsAt),
                Image_URL__c = imageUrl
            );
            insert listing;
            return listing.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static ListingWrapper toWrapper(Auction_Listing__c l) {
        ListingWrapper w = new ListingWrapper();
        w.id = l.Id;
        w.title = l.Title__c;
        w.description = l.Description__c;
        w.category = l.Category__c;
        w.startingPrice = l.Starting_Price__c;
        w.currentBid = l.Current_Bid__c;
        w.currentBidder = l.Current_Bidder__c;
        w.status = l.Status__c;
        w.endsAt = l.Ends_At__c != null ? l.Ends_At__c.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') : null;
        w.imageUrl = l.Image_URL__c;
        return w;
    }
}
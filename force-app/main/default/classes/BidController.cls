public with sharing class BidController {

    public class BidWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String bidderName { get; set; }
        @AuraEnabled public Decimal amount { get; set; }
        @AuraEnabled public String listingId { get; set; }
    }

    @AuraEnabled
    public static BidWrapper placeBid(
        String listingId,
        String bidderName,
        Decimal amount
    ) {
        if (String.isBlank(listingId) || String.isBlank(bidderName) || amount == null) {
            throw new AuraHandledException('All fields are required.');
        }

        Savepoint sp = Database.setSavepoint();
        try {
            Auction_Listing__c listing = [
                SELECT Id, Status__c, Current_Bid__c, Starting_Price__c, Title__c
                FROM Auction_Listing__c
                WHERE Id = :listingId
                LIMIT 1
                FOR UPDATE
            ];

            if (listing.Status__c != 'Active') {
                throw new AuraHandledException('This auction is not active.');
            }

            Decimal threshold = listing.Current_Bid__c != null
                ? listing.Current_Bid__c
                : listing.Starting_Price__c;

            if (amount <= threshold) {
                throw new AuraHandledException(
                    'Bid must be greater than the current bid of ' + threshold
                );
            }

            listing.Current_Bid__c = amount;
            listing.Current_Bidder__c = bidderName;
            update listing;

            Bid__c newBid = new Bid__c();
            newBid.Auction_Listing__c = listing.Id;
            newBid.Amount__c = amount;
            newBid.Bid_Time__c = DateTime.now();
            newBid.Bidder_Name__c = bidderName;
            insert newBid;

            Bid_Placed__e evt = new Bid_Placed__e(
                Listing_Id__c = listing.Id,
                Bidder_Name__c = bidderName,
                New_Bid_Amount__c = amount,
                Title__c = listing.Title__c
            );
            EventBus.publish(evt);

            BidWrapper result = wrapBid(newBid);
            return result;

        } catch (AuraHandledException e) {
            Database.rollback(sp);
            throw e;
        } catch (Exception e) {
            Database.rollback(sp);
            throw new AuraHandledException('Failed to place bid: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<BidWrapper> getBidsInReverseChronologicalOrder(Id auctionListingId) {
        List<Bid__c> bids = [
            SELECT Id, Amount__c, Bidder_Name__c, Auction_Listing__c
            FROM Bid__c
            WHERE Auction_Listing__c = :auctionListingId
            ORDER BY Bid_Time__c DESC, Amount__c DESC
        ];
        List<BidWrapper> wrappers = new List<BidWrapper>();
        for (Bid__c bid : bids) {
            wrappers.add(wrapBid(bid));
        }
        return wrappers;
    }

    private static BidWrapper wrapBid(Bid__c bidRecord) {
        BidWrapper wrapper = new BidWrapper();
        wrapper.id = bidRecord.Id;
        wrapper.bidderName = bidRecord.Bidder_Name__c;
        wrapper.amount = bidRecord.Amount__c;
        wrapper.listingId = bidRecord.Auction_Listing__c;
        return wrapper;
    }
}
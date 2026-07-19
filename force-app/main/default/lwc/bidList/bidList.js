import { LightningElement, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { subscribe, unsubscribe } from 'lightning/empApi';
import getBidsInReverseChronologicalOrder from '@salesforce/apex/BidController.getBidsInReverseChronologicalOrder';

export default class BidList extends LightningElement {
    @api
    listingId;

    bidRecords;
    highestBid = null;
    _subscription = null;

    @wire(getBidsInReverseChronologicalOrder, {auctionListingId: '$listingId'})
    handleBidRecords(result) {
        this.bidRecords = result;
        this.highestBid = null;
        if (result.data) {
            for (let bid of result.data) {
                if (this.highestBid === null || bid.amount > this.highestBid) {
                    this.highestBid = bid.amount;
                }
            }
        }
    }

    connectedCallback() {
        subscribe('/event/Bid_Placed__e', -1, (event) => {
            if (event.data.payload.Listing_Id__c === this.listingId) {
                refreshApex(this.bidRecords);
            }
        }).then(sub => {
            this._subscription = sub;
        });
    }

    disconnectedCallback() {
        if (this._subscription) {
            unsubscribe(this._subscription, () => {});
        }
    }

    get bidRecordsForDisplay() {
        return this.bidRecords && this.bidRecords.data ? this.bidRecords.data : [];
    }
}
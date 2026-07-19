import { LightningElement, api, track } from 'lwc';
import getListing from '@salesforce/apex/AuctionListingController.getListing';
import { subscribe, unsubscribe } from 'lightning/empApi';

const FALLBACK_IMAGE = 'https://placehold.co/800x400/e8e8e8/666?text=No+Image';

export default class AuctionListingDetail extends LightningElement {
    @api listingId;
    @track listing = null;
    @track isLoading = false;

    _subscription = null;

    connectedCallback() {
        this.loadListing();
        subscribe('/event/Bid_Placed__e', -1, (event) => {
            if (event.data.payload.Listing_Id__c === this.listingId) {
                this.loadListing();
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

    loadListing() {
        this.isLoading = true;
        getListing({ listingId: this.listingId })
            .then(result => {
                this.listing = result;
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error loading listing:', error);
                this.isLoading = false;
            });
    }

    handleBidSuccess() {
        this.loadListing();
        this.dispatchEvent(new CustomEvent('bidsuccess'));
    }

    handleImageError(event) {
        event.target.src = FALLBACK_IMAGE;
    }

    get imageUrl() {
        return this.listing && this.listing.imageUrl ? this.listing.imageUrl : FALLBACK_IMAGE;
    }

    get isActive() {
        return this.listing && this.listing.status === 'Active';
    }

    get startingPriceDisplay() {
        return this.listing
            ? new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(this.listing.startingPrice)
            : '';
    }

    get currentBidDisplay() {
        if (!this.listing) return '';
        const amount = this.listing.currentBid || this.listing.startingPrice;
        return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
    }

    get formattedEndsAt() {
        if (!this.listing || !this.listing.endsAt) return '';
        return new Date(this.listing.endsAt).toLocaleString();
    }

    get categoryBadgeClass() {
        if (!this.listing) return 'slds-badge';
        const colors = {
            Tractor: 'slds-badge slds-badge_lightest category-tractor',
            Combine: 'slds-badge slds-badge_lightest category-combine',
            Implement: 'slds-badge slds-badge_lightest category-implement',
            Attachment: 'slds-badge slds-badge_lightest category-attachment'
        };
        return colors[this.listing.category] || 'slds-badge';
    }

    get statusBadgeClass() {
        if (!this.listing) return 'slds-badge';
        return this.listing.status === 'Active' ? 'slds-badge slds-badge_success' : 'slds-badge';
    }
}
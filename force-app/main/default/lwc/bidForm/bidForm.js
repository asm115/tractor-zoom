import { LightningElement, api, track } from 'lwc';
import placeBid from '@salesforce/apex/BidController.placeBid';

export default class BidForm extends LightningElement {
    @api listingId;
    @api currentBid;
    @api startingPrice;

    bidderName = '';
    bidAmount = null;
    isSubmitting = false;
    errorMessage = '';

    handleNameChange(event) {
        this.bidderName = event.target.value;
    }

    handleAmountChange(event) {
        this.bidAmount = parseFloat(event.target.value);
    }

    handleSubmit() {
        this.errorMessage = '';
        if (!this.bidderName.trim()) {
            this.errorMessage = 'Please enter your name.';
            return;
        }
        if (!this.bidAmount || this.bidAmount <= 0) {
            this.errorMessage = 'Please enter a valid bid amount.';
            return;
        }

        this.isSubmitting = true;
        placeBid({
            listingId: this.listingId,
            bidderName: this.bidderName,
            amount: this.bidAmount
        })
            .then(result => {
                this.isSubmitting = false;
                this.bidderName = '';
                this.bidAmount = null;
                this.dispatchEvent(new CustomEvent('bidsuccess', {
                    detail: { bid: result }
                }));
            })
            .catch(error => {
                this.isSubmitting = false;
                this.errorMessage = error.body ? error.body.message : 'An error occurred. Please try again.';
            });
    }

    get submitLabel() {
        return this.isSubmitting ? 'Placing Bid...' : 'Place Bid';
    }
}
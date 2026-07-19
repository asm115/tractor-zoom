import { LightningElement, track } from 'lwc';
import createListing from '@salesforce/apex/AuctionListingController.createListing';

export default class CreateListingForm extends LightningElement {
    title = '';
    category = '';
    startingPrice = null;
    endsAt = '';
    isSubmitting = false;
    errorMessage = '';
    categoryOptions = [
        { label: 'Tractor', value: 'Tractor' },
        { label: 'Combine', value: 'Combine' },
        { label: 'Implement', value: 'Implement' },
        { label: 'Attachment', value: 'Attachment' }
    ];

    handleTitleChange(event) {
        this.title = event.target.value;
    }

    handleCategoryChange(event) {
        this.category = event.detail.value;
    }

    handleEndsAtChange(event) {
        this.endsAt = event.target.value;
    }

    handleStartingPriceChange(event) {
        this.startingPrice = parseFloat(event.target.value);
    }

    handleSubmit() {
        this.errorMessage = '';
        if (!this.title.trim() || !this.category || !this.startingPrice || !this.endsAt) {
            this.errorMessage = 'Title, category, starting price, and end date are required.';
            return;
        }
        this.isSubmitting = true;
        createListing({
            title: this.title,
            description: null,
            category: this.category,
            startingPrice: this.startingPrice,
            endsAt: this.endsAt,
            imageUrl: null
        })
            .then(newId => {
                this.isSubmitting = false;
                this.dispatchEvent(new CustomEvent('created', {
                    detail: { listingId: newId }
                }));
            })
            .catch(error => {
                this.isSubmitting = false;
                this.errorMessage = error.body ? error.body.message : 'Failed to create listing.';
            });
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    get submitLabel() {
        return this.isSubmitting ? 'Creating...' : 'Create Listing';
    }
}
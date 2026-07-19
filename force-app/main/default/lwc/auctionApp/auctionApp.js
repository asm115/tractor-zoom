import { LightningElement } from 'lwc';
import getListings from '@salesforce/apex/AuctionListingController.getListings';

export default class AuctionApp extends LightningElement {
    listings = [];
    isLoading = false;
    selectedListingId = null;
    showCreateForm = false;

    searchTerm = '';
    selectedCategory = '';

    categoryOptions = [
        { label: 'All Categories', value: '' },
        { label: 'Tractor', value: 'Tractor' },
        { label: 'Combine', value: 'Combine' },
        { label: 'Implement', value: 'Implement' },
        { label: 'Attachment', value: 'Attachment' }
    ];

    connectedCallback() {
        this.loadListings();
    }

    loadListings() {
        this.isLoading = true;
        getListings()
            .then(result => {
                this.listings = result.listings;
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error loading listings:', error);
                this.isLoading = false;
            });
    }

    handleSearchChange(event) {
        this.searchTerm = event.detail.value;
        this.loadListings();
    }

    handleCategoryChange(event) {
        this.selectedCategory = event.detail.value;
        this.loadListings();
    }

    handleListingSelect(event) {
        this.selectedListingId = event.detail.listingId;
        this.showCreateForm = false;
    }

    handleShowCreateForm() {
        this.showCreateForm = true;
        this.selectedListingId = null;
    }

    handleCreateCancel() {
        this.showCreateForm = false;
    }

    handleListingCreated(event) {
        this.showCreateForm = false;
        this.selectedListingId = event.detail.listingId;
        this.loadListings();
    }

    handleBidSuccess() {
        this.loadListings();
    }

    get noListings() {
        return !this.isLoading && this.listings.length === 0;
    }
}

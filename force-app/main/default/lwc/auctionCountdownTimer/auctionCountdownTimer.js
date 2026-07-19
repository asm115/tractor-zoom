import { LightningElement, api, track } from 'lwc';

export default class AuctionCountdownTimer extends LightningElement {
    @api endsAt;
    @api status;
    countdownText = '';

    _interval = null;

    connectedCallback() {
        this.updateCountdown();
        this._interval = setInterval(() => this.updateCountdown(), 1000);
    }

    disconnectedCallback() {
        if (this._interval) {
            clearInterval(this._interval);
        }
    }

    updateCountdown() {
        if (this.status === 'Closed') {
            this.countdownText = 'Auction ended';
            return;
        }
        if (!this.endsAt) {
            this.countdownText = '';
            return;
        }

        const now = Date.now();
        const end = new Date(this.endsAt).getTime();
        const diffMs = end - now;

        if (diffMs <= 0) {
            this.countdownText = 'Ending soon';
            return;
        }

        const days = Math.floor(diffMs / (1000 * 60 * 60 * 24));
        const hours = Math.floor((diffMs % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        const minutes = Math.floor((diffMs % (1000 * 60 * 60)) / (1000 * 60));

        if (days > 0) {
            this.countdownText = `${days} day${days !== 1 ? 's' : ''} left`;
        } else if (hours > 0) {
            this.countdownText = `${hours} hour${hours !== 1 ? 's' : ''} left`;
        } else if (minutes > 0) {
            this.countdownText = `${minutes} minute${minutes !== 1 ? 's' : ''} left`;
        } else {
            const seconds = Math.floor(diffMs / 1000);
            this.countdownText = `${seconds} second${seconds !== 1 ? 's' : ''} left`;
        }
    }

    get timerClass() {
        return this.status === 'Closed'
            ? 'slds-text-body_small slds-text-color_weak'
            : 'slds-text-body_small slds-text-color_weak';
    }
}
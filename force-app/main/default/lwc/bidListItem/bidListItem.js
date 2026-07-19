import { LightningElement, api } from 'lwc';

export default class BidListItem extends LightningElement {
    @api
    bid = {};

    @api
    highestBid;

    get isHighestBid() {
        return this.bid.amount === this.highestBid;
    }
}
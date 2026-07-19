# TractorZoom Farm Equipment Auction — Salesforce Take-Home

A Salesforce DX take-home project. Candidates use LWC + Apex to build features on a farm equipment auction platform. The base code is functional with intentional bugs and incomplete features to fix. Please work the way you normally would on the job: use your editor, terminal, docs, search, AI, or any other tools you rely on day to day. All tools are allowed. We’re aiming for 1 - 2 hours of work, no more than that please. The goal is quality over quantity and the ability to speak to your choices. Work through the following steps stopping when you reach time. Ensure all your work is committed and pushed at the end. Please complete this within 5 days and share it back to your HR Representative. When emailing your HR Rep please include any notes or thoughts. The more information you can give back the better. 


---

## Prerequisites

- **Salesforce CLI** (`sf`) v2+: `npm install -g @salesforce/cli`
- **Authorized Dev Hub org**: `sf org login web --set-default-dev-hub`
- **Node.js 22+** and npm
- **VS Code** with the Salesforce Extension Pack (recommended)

---

## Quick Start

```bash
git clone <repo-url>
cd salesforce-takehome
npm install
npm run org:setup
```

`org:setup` runs these steps in sequence:

1. Creates a 7-day scratch org aliased `FarmAuction`
2. Deploys all metadata (objects, Apex classes, LWC components, app)
3. Inserts 9 seed auction listings via `scripts/apex/seedData.apex`
4. Opens the org in your browser

To re-open the scratch org later:

```bash
npm run org:open
```

To delete the scratch org when you are done:

```bash
npm run org:delete
```

---

## Getting Started in the App

Once the org opens, navigate to the **Farm Auction** tab. You should see 9 active equipment listings. Select a listing to view its details and place bids.


## Interview Tasks

This project simulates a real feature branch in a Salesforce auction app. The app is partially built and intentionally includes a few defects. Your goal is to diagnose issues, ship fixes, and implement missing functionality in Apex and LWC.

Complete the following tasks in order:

### Task 0: Clone this repository and push it to your own github as a separate project

### Task 1: Restore app access and fix bid validation
Make sure the org is usable and the **Farm Auction** tab is visible, then fix the bid validation bug so invalid bids are correctly rejected.

### Task 2: Add search and category filtering
Implement listing search and category filters end to end. Resolve related issues you find along the way.

### Task 3: Add bid history with highest bid highlighted
Persist and display bid history so users can see all prior bids for a listing, with the highest bid clearly highlighted.

---
